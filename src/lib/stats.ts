import type { BiomarkerRow } from "@/types";

export function pearson(xs: number[], ys: number[]): number | null {
  const n = Math.min(xs.length, ys.length);
  if (n < 2) return null;
  let sx = 0,
    sy = 0,
    sxx = 0,
    syy = 0,
    sxy = 0;
  for (let i = 0; i < n; i++) {
    const x = xs[i];
    const y = ys[i];
    sx += x;
    sy += y;
    sxx += x * x;
    syy += y * y;
    sxy += x * y;
  }
  const num = n * sxy - sx * sy;
  const den = Math.sqrt((n * sxx - sx * sx) * (n * syy - sy * sy));
  if (den === 0) return null;
  return num / den;
}

export function groupedByPatientDate(rows: BiomarkerRow[]) {
  const map = new Map<string, Record<string, number>>();
  for (const r of rows) {
    const key = `${r.patient_id}|${r.visit_date}`;
    let g = map.get(key);
    if (!g) {
      g = {};
      map.set(key, g);
    }
    g[r.biomarker] = r.value;
  }
  return map;
}

export function correlationMatrix(
  rows: BiomarkerRow[],
  biomarkers: string[],
): Record<string, Record<string, number>> {
  const grouped = groupedByPatientDate(rows);
  const matrix: Record<string, Record<string, number>> = {};
  for (const a of biomarkers) {
    matrix[a] = {};
    for (const b of biomarkers) {
      if (a === b) {
        matrix[a][b] = 1;
        continue;
      }
      const xs: number[] = [];
      const ys: number[] = [];
      for (const rec of grouped.values()) {
        const va = rec[a];
        const vb = rec[b];
        if (va !== undefined && vb !== undefined) {
          xs.push(va);
          ys.push(vb);
        }
      }
      const r = pearson(xs, ys);
      matrix[a][b] = r ?? NaN;
    }
  }
  return matrix;
}

export function summaryStats(
  rows: BiomarkerRow[],
  biomarkers: string[],
): Record<
  string,
  { mean: number; std: number; min: number; max: number; n: number }
> {
  const out: Record<
    string,
    { mean: number; std: number; min: number; max: number; n: number }
  > = {};
  for (const m of biomarkers) {
    const vals = rows.filter((r) => r.biomarker === m).map((r) => r.value);
    const n = vals.length;
    if (n === 0) {
      out[m] = { mean: NaN, std: NaN, min: NaN, max: NaN, n: 0 };
      continue;
    }
    const mean = vals.reduce((a, b) => a + b, 0) / n;
    const variance =
      vals.reduce((acc, v) => acc + (v - mean) ** 2, 0) / Math.max(n - 1, 1);
    out[m] = {
      mean,
      std: Math.sqrt(variance),
      min: Math.min(...vals),
      max: Math.max(...vals),
      n,
    };
  }
  return out;
}
