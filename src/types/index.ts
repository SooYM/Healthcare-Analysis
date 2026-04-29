export type BiomarkerRow = {
  patient_id: string;
  visit_date: string;
  biomarker: string;
  value: number;
  group?: string;
};

export type DataResponse = {
  source: "bigquery" | "demo";
  /** When source is demo, explains why (BigQuery skipped, failed, or placeholder env). */
  demoReason?: string;
  rows: BiomarkerRow[];
  biomarkers: string[];
  biomarkerGroups?: Record<string, string[]>;
  dateRange: { min: string; max: string };
  rowCount: number;
  correlation?: Record<string, Record<string, number>>;
  summary?: Record<
    string,
    { mean: number; std: number; min: number; max: number; n: number }
  >;
};
