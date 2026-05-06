import mysql from "mysql2/promise";
import type { BiomarkerRow } from "@/types";
import type { AppEnv } from "@/lib/env";
import { parseMySQLViewNames } from "@/lib/env";

const datasetIdSafe = /^[A-Za-z0-9_]+$/;

function assertDatasetId(id: string) {
  if (!datasetIdSafe.test(id)) {
    throw new Error(`Invalid MYSQL_DATABASE: ${id}`);
  }
}

async function getConnection(env: AppEnv) {
  return mysql.createConnection({
    host: env.MYSQL_HOST,
    user: env.MYSQL_USER,
    password: env.MYSQL_PASSWORD,
    database: env.MYSQL_DATABASE,
    port: parseInt(env.MYSQL_PORT, 10) || 3306,
    dateStrings: true, // Returns dates/times as strings instead of Date objects
  });
}

async function getNumericColumns(
  connection: mysql.Connection,
  database: string,
  viewNames: string[],
  ignoreCols: string[]
): Promise<Record<string, string[]>> {
  if (viewNames.length === 0) return {};

  const placeholders = viewNames.map(() => "?").join(",");
  const sql = `
    SELECT TABLE_NAME as table_name, COLUMN_NAME as column_name
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = ?
      AND TABLE_NAME IN (${placeholders})
      AND DATA_TYPE IN ('int', 'bigint', 'float', 'double', 'decimal', 'numeric')
  `;

  const [rows] = await connection.execute<mysql.RowDataPacket[]>(sql, [
    database,
    ...viewNames,
  ]);

  const ignoreSet = new Set(ignoreCols.map((c) => c.toLowerCase()));
  const result: Record<string, string[]> = {};

  for (const row of rows) {
    const t = row.table_name;
    const c = row.column_name;
    if (!ignoreSet.has(c.toLowerCase())) {
      if (!result[t]) result[t] = [];
      result[t].push(c);
    }
  }

  return result;
}

function buildUnpivotBranch(
  fullTableId: string,
  tableName: string,
  cols: string[],
  pid: string,
  vd: string,
  includeBiomarkerFilter: boolean,
  hasPatientId: boolean
): string {
  if (!cols || cols.length === 0) return "";

  // For each numeric column, create a SELECT ... UNION ALL block
  const selects = cols.map((c) => {
    let selectSql = `
      SELECT
        CAST(\`${pid}\` AS CHAR) AS patient_id,
        DATE_FORMAT(\`${vd}\`, '%Y-%m-%d') AS visit_date,
        '${c}' AS biomarker,
        CAST(\`${c}\` AS DOUBLE) AS value,
        '${tableName}' AS \`group\`
      FROM ${fullTableId}
      WHERE DATE(\`${vd}\`) BETWEEN ? AND ?
    `;

    // Add filter clauses.  We use placeholders (?) and will supply the params later.
    // However, since we are multiplying the SELECT statements, we need to multiply the params too.
    // Alternatively, we can construct the UNION ALL inside a derived table and filter outside.
    return selectSql;
  });

  // To make parameter binding easier, we construct the unpivot for the table
  // as a derived table and apply the filters on the outer query.
  
  const innerUnpivot = cols.map((c) => `
    SELECT
      \`${pid}\` AS patient_id_raw,
      \`${vd}\` AS visit_date_raw,
      '${c}' AS biomarker,
      CAST(\`${c}\` AS DOUBLE) AS value
    FROM ${fullTableId}
  `).join("\n    UNION ALL\n");

  let branch = `
    SELECT
      CAST(patient_id_raw AS CHAR) AS patient_id,
      DATE_FORMAT(visit_date_raw, '%Y-%m-%d') AS visit_date,
      biomarker,
      value,
      '${tableName}' AS \`group\`
    FROM (
      ${innerUnpivot}
    ) AS unpivoted
    WHERE DATE(visit_date_raw) BETWEEN ? AND ?
  `;

  if (includeBiomarkerFilter) {
    // Instead of using FIND_IN_SET or generating dynamic IN clause, we will construct the IN clause dynamically.
    // The placeholder string will be added in the main function.
    branch += ` AND biomarker IN (<<BIOMARKERS_PLACEHOLDER>>)`;
  }
  if (hasPatientId) {
    branch += ` AND CAST(patient_id_raw AS CHAR) = ?`;
  }

  return branch.trim();
}

export async function queryBiomarkerLong(
  env: AppEnv,
  params: {
    dateFrom: string;
    dateTo: string;
    biomarkers?: string[];
    rowLimit: number;
    patientId?: string;
  }
): Promise<BiomarkerRow[]> {
  const pid = env.MYSQL_COL_PATIENT_ID;
  const vd = env.MYSQL_COL_VISIT_DATE;
  const ignoreCols = [
    pid,
    vd,
    "First_Name",
    "Last_Name",
    "Gender",
    "Age_Category",
  ];

  let database = env.MYSQL_DATABASE;
  let viewNames = parseMySQLViewNames(env);
  let isSingleTable = false;
  let singleTableFqn = env.MYSQL_TABLE_FQN;

  if (viewNames.length === 0) {
    if (!singleTableFqn) {
      throw new Error(
        "Set MYSQL_VIEW_NAMES or MYSQL_TABLE_FQN for MySQL"
      );
    }
    const parts = singleTableFqn.split(".");
    if (parts.length >= 2) {
      database = parts[parts.length - 2];
      viewNames = [parts[parts.length - 1]];
      isSingleTable = true;
    } else {
      viewNames = [singleTableFqn];
      isSingleTable = true;
    }
  } else {
    assertDatasetId(database);
  }

  const biomarkers = params.biomarkers?.filter(Boolean) || [];
  const includeBm = biomarkers.length > 0;
  const hasPatientId = Boolean(params.patientId?.trim());

  const connection = await getConnection(env);

  try {
    const tableColumns = await getNumericColumns(
      connection,
      database,
      viewNames,
      ignoreCols
    );

    const branches: string[] = [];
    // We will collect parameters for all branches
    const queryParams: any[] = [];

    const biomarkerPlaceholders = includeBm
      ? biomarkers.map(() => "?").join(",")
      : "";

    for (const name of viewNames) {
      const cols = tableColumns[name] || [];
      const fullId = isSingleTable
        ? `\`${name}\``
        : `\`${database}\`.\`${name}\``;
      
      let branch = buildUnpivotBranch(
        fullId,
        name,
        cols,
        pid,
        vd,
        includeBm,
        hasPatientId
      );

      if (branch) {
        if (includeBm) {
            branch = branch.replace("<<BIOMARKERS_PLACEHOLDER>>", biomarkerPlaceholders);
        }

        branches.push(branch);

        // Add parameters for this branch
        queryParams.push(params.dateFrom, params.dateTo);
        if (includeBm) {
          queryParams.push(...biomarkers);
        }
        if (hasPatientId) {
          queryParams.push(params.patientId);
        }
      }
    }

    if (branches.length === 0) {
      return []; // No numeric columns found to unpivot
    }

    const sql = `
      SELECT * FROM (
        ${branches.join("\n      UNION ALL\n")}
      ) AS _union_all
      ORDER BY visit_date, patient_id, biomarker
      LIMIT ?
    `;

    queryParams.push(params.rowLimit);

    const [rows] = await connection.execute<mysql.RowDataPacket[]>(
      sql,
      queryParams
    );

    return rows.map((r) => ({
      patient_id: String(r.patient_id ?? ""),
      visit_date: String(r.visit_date ?? ""),
      biomarker: String(r.biomarker ?? ""),
      value: Number(r.value),
      group: r.group ? String(r.group) : undefined,
    }));
  } finally {
    await connection.end();
  }
}

export async function queryDistinctPatients(env: AppEnv): Promise<string[]> {
  const pid = env.MYSQL_COL_PATIENT_ID;

  let database = env.MYSQL_DATABASE;
  let viewNames = parseMySQLViewNames(env);
  let isSingleTable = false;
  let singleTableFqn = env.MYSQL_TABLE_FQN;

  if (viewNames.length === 0) {
    if (!singleTableFqn) {
      throw new Error(
        "Set MYSQL_VIEW_NAMES or MYSQL_TABLE_FQN for MySQL"
      );
    }
    const parts = singleTableFqn.split(".");
    if (parts.length >= 2) {
      database = parts[parts.length - 2];
      viewNames = [parts[parts.length - 1]];
      isSingleTable = true;
    } else {
      viewNames = [singleTableFqn];
      isSingleTable = true;
    }
  }

  if (viewNames.length === 0) return [];

  const name = viewNames[0];
  const fullId = isSingleTable ? `\`${name}\`` : `\`${database}\`.\`${name}\``;

  const sql = `
    SELECT DISTINCT CAST(\`${pid}\` AS CHAR) AS patient_id
    FROM ${fullId}
    WHERE \`${pid}\` IS NOT NULL
    ORDER BY 1
  `;

  const connection = await getConnection(env);
  try {
    const [rows] = await connection.execute<mysql.RowDataPacket[]>(sql);
    return rows.map((r) => String(r.patient_id));
  } finally {
    await connection.end();
  }
}
