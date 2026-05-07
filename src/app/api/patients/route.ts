import { NextResponse } from "next/server";
import { getServerEnv, isDemoMode, parseBigQueryViewNames } from "@/lib/env";
import { queryDistinctPatients } from "@/lib/bigquery";

export async function GET() {
  const env = getServerEnv();

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

  if (useBigQuery) {
    try {
      const patientIds = await queryDistinctPatients(env);
      return NextResponse.json({
        patientIds,
        totalReports: patientIds.length,
      });
    } catch (e) {
      console.error("BigQuery error fetching patients, falling back to demo:", e);
    }
  }

  // Fallback to Demo Data
  const patientIds = Array.from({ length: 48 }, (_, i) => `P${String(i + 1).padStart(4, "0")}`);
  return NextResponse.json({
    patientIds,
    totalReports: patientIds.length,
  });
}
