import { z } from "zod";

const envSchema = z.object({
  GCP_PROJECT_ID: z.string().optional(),
  MYSQL_HOST: z.string().default("localhost"),
  MYSQL_USER: z.string().default("root"),
  MYSQL_PASSWORD: z.string().default(""),
  MYSQL_DATABASE: z.string().default("healthcare_dashboard"),
  MYSQL_PORT: z.string().default("3306"),
  /** Comma-separated view/table names (UNION ALL long-format rows) */
  MYSQL_VIEW_NAMES: z.string().optional(),
  /** Fully qualified table: database.table — used when MYSQL_VIEW_NAMES is empty */
  MYSQL_TABLE_FQN: z.string().optional(),
  /** Column names in your table (long / tidy format) */
  MYSQL_COL_PATIENT_ID: z.string().default("patient_id"),
  MYSQL_COL_VISIT_DATE: z.string().default("visit_date"),
  MYSQL_COL_BIOMARKER: z.string().default("biomarker"),
  MYSQL_COL_VALUE: z.string().default("value"),
  VERTEX_LOCATION: z.string().default("us-central1"),
  VERTEX_MODEL: z.string().default("gemini-1.5-flash"),
  HUGGINGFACE_MODEL: z.string().default("google/medgemma-27b-text-it"),
});

export type AppEnv = z.infer<typeof envSchema>;

export function getServerEnv(): AppEnv {
  return envSchema.parse({
    GCP_PROJECT_ID: process.env.GCP_PROJECT_ID,
    MYSQL_HOST: process.env.MYSQL_HOST,
    MYSQL_USER: process.env.MYSQL_USER,
    MYSQL_PASSWORD: process.env.MYSQL_PASSWORD,
    MYSQL_DATABASE: process.env.MYSQL_DATABASE,
    MYSQL_PORT: process.env.MYSQL_PORT,
    MYSQL_VIEW_NAMES: process.env.MYSQL_VIEW_NAMES,
    MYSQL_TABLE_FQN: process.env.MYSQL_TABLE_FQN,
    MYSQL_COL_PATIENT_ID: process.env.MYSQL_COL_PATIENT_ID,
    MYSQL_COL_VISIT_DATE: process.env.MYSQL_COL_VISIT_DATE,
    MYSQL_COL_BIOMARKER: process.env.MYSQL_COL_BIOMARKER,
    MYSQL_COL_VALUE: process.env.MYSQL_COL_VALUE,
    VERTEX_LOCATION: process.env.VERTEX_LOCATION,
    VERTEX_MODEL: process.env.VERTEX_MODEL,
    HUGGINGFACE_MODEL: process.env.HUGGINGFACE_MODEL,
  });
}

export function isDemoMode(): boolean {
  return process.env.DEMO_MODE === "true";
}

/** Parsed, non-empty view names from MYSQL_VIEW_NAMES (comma-separated). */
export function parseMySQLViewNames(env: AppEnv): string[] {
  const raw = env.MYSQL_VIEW_NAMES;
  if (!raw?.trim()) return [];
  const names = raw
    .split(",")
    .map((s) => s.trim())
    .filter(Boolean);
  const safe = /^[A-Za-z_][A-Za-z0-9_]*$/;
  return names.filter((n) => {
    if (!safe.test(n)) {
      console.warn(`Skipping invalid MySQL view name: ${n}`);
      return false;
    }
    return true;
  });
}
