import { NextResponse } from "next/server";
import { getServerEnv, isDemoMode, parseMySQLViewNames } from "@/lib/env";
import { queryDistinctPatients } from "@/lib/mysql";

export async function GET() {
  const env = getServerEnv();

  const viewNames = parseMySQLViewNames(env);
  const hasUnion = viewNames.length > 0;

  const tableFqn = env.MYSQL_TABLE_FQN ?? "";
  const hasSingle = Boolean(tableFqn);

  const useMySQL =
    !isDemoMode() &&
    (hasUnion || hasSingle);

  if (useMySQL) {
    try {
      const patientIds = await queryDistinctPatients(env);
      return NextResponse.json({
        patientIds,
        totalReports: patientIds.length,
      });
    } catch (e) {
      console.error("MySQL error fetching patients, falling back to demo:", e);
    }
  }

  // Fallback to Demo Data
  const patientIds = Array.from({ length: 48 }, (_, i) => `P${String(i + 1).padStart(4, "0")}`);
  return NextResponse.json({
    patientIds,
    totalReports: patientIds.length,
  });
}
