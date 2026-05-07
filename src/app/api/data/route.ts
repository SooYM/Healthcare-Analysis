import { NextResponse } from "next/server";
import { z } from "zod";
import {
  getServerEnv,
  isDemoMode,
  parseBigQueryViewNames,
} from "@/lib/env";
import { queryBiomarkerLong } from "@/lib/bigquery";
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

  const viewNames = parseBigQueryViewNames(env);
  const hasUnion = viewNames.length > 0;

  const tableFqn = env.BIGQUERY_TABLE_FQN ?? "";
  const placeholderTable =
    tableFqn.includes("REPLACE_ME") || tableFqn.endsWith(".A2.");
  const hasSingle = Boolean(tableFqn) && !placeholderTable;

  const useBigQuery =
    !isDemoMode() &&
    Boolean(env.GCP_PROJECT_ID) &&
    (hasUnion || hasSingle);

  if (isDemoMode()) {
    demoReason = "DEMO_MODE=true — set DEMO_MODE=false to use BigQuery.";
    rows = generateDemoRows({ dateFrom, dateTo, biomarkerFilter: biomarkers, patientId });
  } else if (!env.GCP_PROJECT_ID) {
    demoReason =
      "Set GCP_PROJECT_ID in .env.local (and GOOGLE_APPLICATION_CREDENTIALS if using a service account).";
    rows = generateDemoRows({ dateFrom, dateTo, biomarkerFilter: biomarkers, patientId });
  } else if (!hasUnion && !hasSingle) {
    demoReason =
      "BigQuery not configured: set BIGQUERY_VIEW_NAMES (comma-separated views in dataset A2) or a valid BIGQUERY_TABLE_FQN.";
    rows = generateDemoRows({ dateFrom, dateTo, biomarkerFilter: biomarkers, patientId });
  } else if (!hasUnion && placeholderTable) {
    demoReason =
      "BIGQUERY_TABLE_FQN still has a placeholder (e.g. REPLACE_ME). Either set BIGQUERY_VIEW_NAMES for multiple views or set BIGQUERY_TABLE_FQN to a real table.";
    rows = generateDemoRows({ dateFrom, dateTo, biomarkerFilter: biomarkers, patientId });
  } else if (useBigQuery) {
    try {
      rows = await queryBiomarkerLong(env, {
        dateFrom,
        dateTo,
        biomarkers,
        rowLimit,
        patientId,
      });
      source = "bigquery";
    } catch (e) {
      const msg = e instanceof Error ? e.message : String(e);
      console.error("BigQuery error, falling back to demo:", e);
      demoReason = `BigQuery query failed (showing demo data): ${msg}`;
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
