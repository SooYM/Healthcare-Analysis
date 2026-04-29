import type { BiomarkerRow } from "@/types";

const BIOMARKERS = [
  "glucose_mg_dl",
  "hba1c_pct",
  "creatinine_mg_dl",
  "alt_u_l",
  "hemoglobin_g_dl",
  "wbc_k_ul",
];

function hashSeed(s: string): number {
  let h = 0;
  for (let i = 0; i < s.length; i++) h = (h << 5) - h + s.charCodeAt(i);
  return Math.abs(h);
}

/** Deterministic synthetic longitudinal biomarker data for local demo */
export function generateDemoRows(options: {
  dateFrom: string;
  dateTo: string;
  biomarkerFilter?: string[];
  patientId?: string;
}): BiomarkerRow[] {
  const from = new Date(options.dateFrom);
  const to = new Date(options.dateTo);
  if (from > to) return [];
  const filter = options.biomarkerFilter?.length
    ? options.biomarkerFilter
    : BIOMARKERS;
  const rows: BiomarkerRow[] = [];
  
  let patientIds = Array.from({ length: 48 }, (_, i) => `P${String(i + 1).padStart(4, "0")}`);
  if (options.patientId && options.patientId.trim()) {
    patientIds = [options.patientId.trim()];
  }

  for (const pid of patientIds) {
    const seed = hashSeed(pid);
    let glucoseDrift = (seed % 40) / 100;
    for (let d = new Date(from); d <= to; d.setMonth(d.getMonth() + 1)) {
      const iso = d.toISOString().slice(0, 10);
      const t = d.getTime() / (1000 * 60 * 60 * 24);
      for (const name of filter) {
        let base = 90 + (seed % 30);
        if (name.includes("hba1c")) base = 5.2 + (seed % 15) / 100;
        if (name.includes("creatinine")) base = 0.9 + (seed % 20) / 100;
        if (name.includes("alt")) base = 22 + (seed % 25);
        if (name.includes("hemoglobin")) base = 13 + (seed % 30) / 10;
        if (name.includes("wbc")) base = 6 + (seed % 40) / 10;
        if (name.includes("glucose")) {
          base += glucoseDrift * 3;
          glucoseDrift += (seed % 7) / 1000 - 0.002;
        }
        const noise = Math.sin(t / 40 + seed) * (base * 0.04);
        const value = Math.round((base + noise) * 1000) / 1000;
        rows.push({
          patient_id: pid,
          visit_date: iso,
          biomarker: name,
          value,
        });
      }
    }
  }
  return rows.sort(
    (a, b) =>
      a.visit_date.localeCompare(b.visit_date) ||
      a.patient_id.localeCompare(b.patient_id),
  );
}

export const DEMO_BIOMARKERS = BIOMARKERS;
