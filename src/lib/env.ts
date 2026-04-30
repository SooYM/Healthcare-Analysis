import { z } from "zod";

const envSchema = z.object({
  GCP_PROJECT_ID: z.string().optional(),
  BIGQUERY_LOCATION: z.string().default("US"),
  /** Dataset id when using BIGQUERY_VIEW_NAMES (default A2) */
  BIGQUERY_DATASET: z.string().default("A2"),
  /** Comma-separated view/table names in BIGQUERY_DATASET (UNION ALL long-format rows) */
  BIGQUERY_VIEW_NAMES: z.string().optional(),
  /** Fully qualified table: project.dataset.table — used when BIGQUERY_VIEW_NAMES is empty */
  BIGQUERY_TABLE_FQN: z.string().optional(),
  /** Column names in your table (long / tidy format) */
  BQ_COL_PATIENT_ID: z.string().default("patient_id"),
  BQ_COL_VISIT_DATE: z.string().default("visit_date"),
  BQ_COL_BIOMARKER: z.string().default("biomarker"),
  BQ_COL_VALUE: z.string().default("value"),
  VERTEX_LOCATION: z.string().default("us-central1"),
  VERTEX_MODEL: z.string().default("gemini-1.5-flash"),
  HUGGINGFACE_MODEL: z.string().default("google/medgemma-27b-text-it"),
});

export type AppEnv = z.infer<typeof envSchema>;

export function getServerEnv(): AppEnv {
  return envSchema.parse({
    GCP_PROJECT_ID: process.env.GCP_PROJECT_ID,
    BIGQUERY_LOCATION: process.env.BIGQUERY_LOCATION,
    BIGQUERY_DATASET: process.env.BIGQUERY_DATASET,
    BIGQUERY_VIEW_NAMES: process.env.BIGQUERY_VIEW_NAMES,
    BIGQUERY_TABLE_FQN: process.env.BIGQUERY_TABLE_FQN,
    BQ_COL_PATIENT_ID: process.env.BQ_COL_PATIENT_ID,
    BQ_COL_VISIT_DATE: process.env.BQ_COL_VISIT_DATE,
    BQ_COL_BIOMARKER: process.env.BQ_COL_BIOMARKER,
    BQ_COL_VALUE: process.env.BQ_COL_VALUE,
    VERTEX_LOCATION: process.env.VERTEX_LOCATION,
    VERTEX_MODEL: process.env.VERTEX_MODEL,
    HUGGINGFACE_MODEL: process.env.HUGGINGFACE_MODEL,
  });
}

export function isDemoMode(): boolean {
  return process.env.DEMO_MODE === "true";
}

/** Parsed, non-empty view names from BIGQUERY_VIEW_NAMES (comma-separated). */
export function parseBigQueryViewNames(env: AppEnv): string[] {
  const raw = env.BIGQUERY_VIEW_NAMES;
  if (!raw?.trim()) return [];
  const names = raw
    .split(",")
    .map((s) => s.trim())
    .filter(Boolean);
  const safe = /^[A-Za-z_][A-Za-z0-9_]*$/;
  return names.filter((n) => {
    if (!safe.test(n)) {
      console.warn(`Skipping invalid BigQuery view name: ${n}`);
      return false;
    }
    return true;
  });
}
