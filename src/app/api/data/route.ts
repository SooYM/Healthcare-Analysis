import { NextResponse } from "next/server";
import { z } from "zod";
import {
  getServerEnv,
  isDemoMode,
  parseMySQLViewNames,
} from "@/lib/env";
import { queryBiomarkerLong } from "@/lib/mysql";
import { generateDemoRows } from "@/lib/demo-data";
import { correlationMatrix, summaryStats } from "@/lib/stats";
import type { DataResponse } from "@/types";

const bodySchema = z.object({
  dateFrom: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  dateTo: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  biomarkers: z.array(z.string()).optional(),
  rowLimit: z.number().int().min(100).max(200000).optional().default(50000),
  patientId: z.string().optional(),
});

export async function POST(req: Request) {
  let json: unknown;
  try {
    json = await req.json();
  } catch {
    return NextResponse.json({ error: "Invalid JSON body" }, { status: 400 });
  }

  const parsed = bodySchema.safeParse(json);
  if (!parsed.success) {
    return NextResponse.json(
      { error: "Validation failed", details: parsed.error.flatten() },
      { status: 400 },
    );
  }

  const { dateFrom, dateTo, biomarkers, rowLimit, patientId } = parsed.data;
  const env = getServerEnv();

  let rows;
  let source: DataResponse["source"] = "demo";
  let demoReason: string | undefined;

  const viewNames = parseMySQLViewNames(env);
  const hasUnion = viewNames.length > 0;

  const tableFqn = env.MYSQL_TABLE_FQN ?? "";
  const hasSingle = Boolean(tableFqn);

  const useMySQL =
    !isDemoMode() &&
    (hasUnion || hasSingle);

  if (isDemoMode()) {
    demoReason = "DEMO_MODE=true — set DEMO_MODE=false to use MySQL.";
    rows = generateDemoRows({ dateFrom, dateTo, biomarkerFilter: biomarkers, patientId });
  } else if (!hasUnion && !hasSingle) {
    demoReason =
      "MySQL not configured: set MYSQL_VIEW_NAMES (comma-separated views) or a valid MYSQL_TABLE_FQN.";
    rows = generateDemoRows({ dateFrom, dateTo, biomarkerFilter: biomarkers, patientId });
  } else if (useMySQL) {
    try {
      rows = await queryBiomarkerLong(env, {
        dateFrom,
        dateTo,
        biomarkers,
        rowLimit,
        patientId,
      });
      source = "bigquery"; // Keep bigquery as source type for now to avoid breaking types, or change it if we modify types.ts
    } catch (e) {
      const msg = e instanceof Error ? e.message : String(e);
      console.error("MySQL error, falling back to demo:", e);
      demoReason = `MySQL query failed (showing demo data): ${msg}`;
      rows = generateDemoRows({ dateFrom, dateTo, biomarkerFilter: biomarkers, patientId });
      source = "demo";
    }
  } else {
    rows = generateDemoRows({ dateFrom, dateTo, biomarkerFilter: biomarkers, patientId });
  }

  const biomarkerSet = new Set(rows.map((r) => r.biomarker));
  const biomarkerList = Array.from(biomarkerSet).sort();
  const dates = rows.map((r) => r.visit_date).sort();
  const correlation = correlationMatrix(rows, biomarkerList);
  const summary = summaryStats(rows, biomarkerList);

  const biomarkerGroups: Record<string, string[]> = {};
  for (const r of rows) {
    if (r.group && r.biomarker) {
      if (!biomarkerGroups[r.group]) {
        biomarkerGroups[r.group] = [];
      }
      if (!biomarkerGroups[r.group].includes(r.biomarker)) {
        biomarkerGroups[r.group].push(r.biomarker);
      }
    }
  }

  const payload: DataResponse = {
    source,
    ...(demoReason ? { demoReason } : {}),
    rows,
    biomarkers: biomarkerList,
    biomarkerGroups: Object.keys(biomarkerGroups).length > 0 ? biomarkerGroups : undefined,
    dateRange: {
      min: dates[0] ?? dateFrom,
      max: dates[dates.length - 1] ?? dateTo,
    },
    rowCount: rows.length,
    correlation,
    summary,
  };

  return NextResponse.json(payload);
}
