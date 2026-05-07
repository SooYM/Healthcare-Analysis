import { BigQuery } from "@google-cloud/bigquery";
import type { BiomarkerRow } from "@/types";
import type { AppEnv } from "@/lib/env";
import { parseBigQueryViewNames } from "@/lib/env";

const datasetIdSafe = /^[A-Za-z0-9_]+$/;

function assertDatasetId(id: string) {
  if (!datasetIdSafe.test(id)) {
    throw new Error(`Invalid BIGQUERY_DATASET: ${id}`);
  }
}

async function getNumericColumns(
  client: BigQuery,
  project: string,
  dataset: string,
  viewNames: string[],
  ignoreCols: string[]
): Promise<Record<string, string[]>> {
  if (viewNames.length === 0) return {};
  
  const sql = `
    SELECT table_name, column_name
    FROM \`${project}.${dataset}.INFORMATION_SCHEMA.COLUMNS\`
    WHERE table_name IN UNNEST(@viewNames)
      AND data_type IN ('INT64', 'FLOAT64', 'NUMERIC', 'BIGNUMERIC')
  `;
  
  const [job] = await client.createQueryJob({
    query: sql,
    params: { viewNames },
  });
  
  const [rows] = await job.getQueryResults();
  
  const ignoreSet = new Set(ignoreCols.map(c => c.toLowerCase()));
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
  if (!cols || cols.length === 0) return '';
  
  const quotedCols = cols.map(c => `\`${c}\``).join(', ');
  const castCols = cols.map(c => `CAST(\`${c}\` AS FLOAT64) AS \`${c}\``).join(',\n      ');
  
  let branch = `
    SELECT
      CAST(\`${pid}\` AS STRING) AS patient_id,
      FORMAT_DATE('%Y-%m-%d', DATE(\`${vd}\`)) AS visit_date,
      CAST(biomarker AS STRING) AS biomarker,
      value,
      '${tableName}' AS \`group\`
    FROM (
      SELECT
        \`${pid}\`,
        \`${vd}\`,
        ${castCols}
      FROM \`${fullTableId}\`
    )
    UNPIVOT(
      value FOR biomarker IN (${quotedCols})
    )
    WHERE DATE(\`${vd}\`) BETWEEN @dateFrom AND @dateTo
  `;
  
  if (includeBiomarkerFilter) {
    branch += ` AND biomarker IN UNNEST(@biomarkers)`;
  }
  if (hasPatientId) {
    branch += ` AND CAST(\`${pid}\` AS STRING) = @patientId`;
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
  },
): Promise<BiomarkerRow[]> {
  const project = env.GCP_PROJECT_ID;
  if (!project) {
    throw new Error("GCP_PROJECT_ID is required");
  }

  const client = new BigQuery({
    projectId: project,
    location: env.BIGQUERY_LOCATION,
  });

  const pid = env.BQ_COL_PATIENT_ID;
  const vd = env.BQ_COL_VISIT_DATE;
  const ignoreCols = [pid, vd, 'First_Name', 'Last_Name', 'Gender', 'Age_Category'];

  let dataset = env.BIGQUERY_DATASET;
  let viewNames = parseBigQueryViewNames(env);
  let isSingleTable = false;
  let singleTableFqn = env.BIGQUERY_TABLE_FQN;

  if (viewNames.length === 0) {
    if (!singleTableFqn) {
      throw new Error("Set BIGQUERY_VIEW_NAMES or BIGQUERY_TABLE_FQN with GCP_PROJECT_ID for BigQuery");
    }
    // Try to parse dataset and table from FQN: project.dataset.table
    const parts = singleTableFqn.split('.');
    if (parts.length >= 2) {
      dataset = parts[parts.length - 2];
      viewNames = [parts[parts.length - 1]];
      isSingleTable = true;
    } else {
      throw new Error(`Invalid BIGQUERY_TABLE_FQN: ${singleTableFqn}. Must be project.dataset.table`);
    }
  } else {
    assertDatasetId(dataset);
  }

  const biomarkers = params.biomarkers?.filter(Boolean);
  const includeBm = Boolean(biomarkers?.length);
  const hasPatientId = Boolean(params.patientId?.trim());

  const tableColumns = await getNumericColumns(client, project, dataset, viewNames, ignoreCols);

  const branches: string[] = [];
  for (const name of viewNames) {
    const cols = tableColumns[name] || [];
    const fullId = isSingleTable ? singleTableFqn! : `${project}.${dataset}.${name}`;
    const branch = buildUnpivotBranch(fullId, name, cols, pid, vd, includeBm, hasPatientId);
    if (branch) branches.push(branch);
  }

  if (branches.length === 0) {
    return []; // No numeric columns found to unpivot
  }

  const sql = `
    SELECT * FROM (
      ${branches.join("\n    UNION ALL\n")}
    ) AS _union_all
    ORDER BY visit_date, patient_id, biomarker
    LIMIT @rowLimit
  `;

  const queryParams: Record<string, string | number | string[] | undefined> = {
    dateFrom: params.dateFrom,
    dateTo: params.dateTo,
    rowLimit: params.rowLimit,
  };

  if (includeBm) {
    queryParams.biomarkers = biomarkers;
  }
  if (hasPatientId) {
    queryParams.patientId = params.patientId;
  }

  const [job] = await client.createQueryJob({
    query: sql,
    params: queryParams,
    maximumBytesBilled: "5000000000",
  });

  const [rows] = await job.getQueryResults();
  return rows.map((r) => ({
    patient_id: String(r.patient_id ?? ""),
    visit_date: String(r.visit_date ?? ""),
    biomarker: String(r.biomarker ?? ""),
    value: Number(r.value),
    group: r.group ? String(r.group) : undefined,
  }));
}

export async function queryDistinctPatients(env: AppEnv): Promise<string[]> {
  const project = env.GCP_PROJECT_ID;
  if (!project) {
    throw new Error("GCP_PROJECT_ID is required");
  }

  const client = new BigQuery({
    projectId: project,
    location: env.BIGQUERY_LOCATION,
  });

  const pid = env.BQ_COL_PATIENT_ID;

  let dataset = env.BIGQUERY_DATASET;
  let viewNames = parseBigQueryViewNames(env);
  let isSingleTable = false;
  let singleTableFqn = env.BIGQUERY_TABLE_FQN;

  if (viewNames.length === 0) {
    if (!singleTableFqn) {
      throw new Error("Set BIGQUERY_VIEW_NAMES or BIGQUERY_TABLE_FQN with GCP_PROJECT_ID for BigQuery");
    }
    const parts = singleTableFqn.split('.');
    if (parts.length >= 2) {
      dataset = parts[parts.length - 2];
      viewNames = [parts[parts.length - 1]];
      isSingleTable = true;
    } else {
      throw new Error(`Invalid BIGQUERY_TABLE_FQN: ${singleTableFqn}`);
    }
  }

  if (viewNames.length === 0) return [];

  // To be safe and efficient, we query distinct patients from the first available view/table.
  // Assuming all views share the same base cohort of patients.
  const name = viewNames[0];
  const fullId = isSingleTable ? singleTableFqn! : `${project}.${dataset}.${name}`;

  const sql = `
    SELECT DISTINCT CAST(\`${pid}\` AS STRING) AS patient_id
    FROM \`${fullId}\`
    WHERE \`${pid}\` IS NOT NULL
    ORDER BY 1
  `;

  const [job] = await client.createQueryJob({ query: sql });
  const [rows] = await job.getQueryResults();
  return rows.map((r) => String(r.patient_id));
}
