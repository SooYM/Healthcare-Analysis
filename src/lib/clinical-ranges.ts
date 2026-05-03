/**
 * Clinical reference ranges for biomarkers found in the BigQuery dataset.
 * Used to enrich LLM prompts with medical context so MedGemma can
 * identify abnormal values and provide clinically meaningful analysis.
 */

export type RefRange = {
  low: number;
  high: number;
  unit: string;
  /** What elevated values may indicate */
  highMeaning?: string;
  /** What low values may indicate */
  lowMeaning?: string;
};

/** Lookup: biomarker column name → clinical reference range */
export const CLINICAL_RANGES: Record<string, RefRange> = {
  // ── CBC ──
  Hemoglobin:        { low: 12.0, high: 17.5, unit: "g/dL", highMeaning: "polycythemia, dehydration", lowMeaning: "anemia, blood loss" },
  RBC_Count:         { low: 4.0,  high: 6.0,  unit: "×10⁶/µL", highMeaning: "polycythemia", lowMeaning: "anemia" },
  Hematocrit:        { low: 36,   high: 52,   unit: "%", highMeaning: "dehydration, polycythemia", lowMeaning: "anemia" },
  MCV:               { low: 80,   high: 100,  unit: "fL", highMeaning: "macrocytic anemia (B12/folate deficiency)", lowMeaning: "microcytic anemia (iron deficiency)" },
  MCH:               { low: 27,   high: 33,   unit: "pg", highMeaning: "macrocytosis", lowMeaning: "hypochromia" },
  MCHC:              { low: 32,   high: 36,   unit: "g/dL", highMeaning: "spherocytosis", lowMeaning: "iron deficiency" },
  RDW_CV:            { low: 11.5, high: 14.5, unit: "%", highMeaning: "anisocytosis, mixed anemia", lowMeaning: "normal variation" },
  WBC_Count:         { low: 4.0,  high: 11.0, unit: "×10³/µL", highMeaning: "infection, inflammation, leukemia", lowMeaning: "immunosuppression, bone marrow failure" },
  Neutrophils:       { low: 40,   high: 70,   unit: "%", highMeaning: "bacterial infection", lowMeaning: "viral infection, neutropenia" },
  Lymphocytes:       { low: 20,   high: 40,   unit: "%", highMeaning: "viral infection, CLL", lowMeaning: "immunodeficiency" },
  Platelet_Count:    { low: 150,  high: 400,  unit: "×10³/µL", highMeaning: "thrombocytosis, inflammation", lowMeaning: "thrombocytopenia, bleeding risk" },

  // ── Liver Function ──
  ALP:               { low: 44,   high: 147,  unit: "U/L", highMeaning: "cholestasis, bone disease", lowMeaning: "malnutrition" },
  ALT_SGPT:          { low: 7,    high: 56,   unit: "U/L", highMeaning: "liver damage, hepatitis", lowMeaning: "normal" },
  AST_SGOT:          { low: 10,   high: 40,   unit: "U/L", highMeaning: "liver damage, MI, muscle injury", lowMeaning: "normal" },
  GGT:               { low: 0,    high: 65,   unit: "U/L", highMeaning: "cholestasis, alcohol use, liver disease", lowMeaning: "normal" },
  Bilirubin_Total:   { low: 0.1,  high: 1.2,  unit: "mg/dL", highMeaning: "jaundice, liver disease, hemolysis", lowMeaning: "normal" },
  Bilirubin_Direct:  { low: 0,    high: 0.3,  unit: "mg/dL", highMeaning: "obstructive jaundice", lowMeaning: "normal" },
  Bilirubin_Indirect:{ low: 0.1,  high: 0.8,  unit: "mg/dL", highMeaning: "hemolytic anemia, Gilbert syndrome", lowMeaning: "normal" },
  Protein_Total:     { low: 6.0,  high: 8.3,  unit: "g/dL", highMeaning: "dehydration, chronic inflammation", lowMeaning: "malnutrition, liver disease" },
  Albumin:           { low: 3.5,  high: 5.5,  unit: "g/dL", highMeaning: "dehydration", lowMeaning: "liver disease, nephrotic syndrome" },
  Globulin:          { low: 2.0,  high: 3.5,  unit: "g/dL", highMeaning: "chronic infection, myeloma", lowMeaning: "immunodeficiency" },
  A_G_Ratio:         { low: 1.0,  high: 2.5,  unit: "ratio", highMeaning: "rare", lowMeaning: "liver disease, kidney disease" },

  // ── Kidney Function ──
  Creatinine:        { low: 0.6,  high: 1.2,  unit: "mg/dL", highMeaning: "renal impairment", lowMeaning: "low muscle mass" },
  Urea:              { low: 15,   high: 45,   unit: "mg/dL", highMeaning: "renal dysfunction, dehydration", lowMeaning: "liver disease" },
  BUN:               { low: 7,    high: 20,   unit: "mg/dL", highMeaning: "kidney disease, dehydration", lowMeaning: "liver disease" },
  BUN_Creatinine_Ratio: { low: 10, high: 20, unit: "ratio", highMeaning: "pre-renal azotemia, GI bleed", lowMeaning: "liver disease, malnutrition" },
  eGFR:              { low: 90,   high: 120,  unit: "mL/min/1.73m²", highMeaning: "normal/high filtration", lowMeaning: "chronic kidney disease" },
  Uric_Acid:         { low: 2.5,  high: 7.0,  unit: "mg/dL", highMeaning: "gout, kidney stones", lowMeaning: "Fanconi syndrome" },
  Sodium:            { low: 136,  high: 145,  unit: "mEq/L", highMeaning: "hypernatremia, dehydration", lowMeaning: "hyponatremia, SIADH" },
  Potassium:         { low: 3.5,  high: 5.0,  unit: "mEq/L", highMeaning: "hyperkalemia, cardiac risk", lowMeaning: "hypokalemia, muscle weakness" },
  Chloride:          { low: 98,   high: 106,  unit: "mEq/L", highMeaning: "metabolic acidosis", lowMeaning: "metabolic alkalosis" },

  // ── Lipid Profile ──
  Total_Cholesterol: { low: 0,    high: 200,  unit: "mg/dL", highMeaning: "cardiovascular risk", lowMeaning: "malnutrition" },
  HDL:               { low: 40,   high: 60,   unit: "mg/dL", highMeaning: "cardioprotective", lowMeaning: "cardiovascular risk" },
  LDL:               { low: 0,    high: 100,  unit: "mg/dL", highMeaning: "atherosclerosis risk", lowMeaning: "normal" },
  VLDL:              { low: 2,    high: 30,   unit: "mg/dL", highMeaning: "metabolic syndrome", lowMeaning: "normal" },
  Triglycerides:     { low: 0,    high: 150,  unit: "mg/dL", highMeaning: "pancreatitis risk, metabolic syndrome", lowMeaning: "malnutrition" },
  Total_HDL_Ratio:   { low: 0,    high: 5.0,  unit: "ratio", highMeaning: "high cardiovascular risk", lowMeaning: "low risk" },
  LDL_HDL_Ratio:     { low: 0,    high: 3.5,  unit: "ratio", highMeaning: "high cardiovascular risk", lowMeaning: "low risk" },

  // ── Glucose & HbA1c ──
  Fasting_Glucose:   { low: 70,   high: 100,  unit: "mg/dL", highMeaning: "prediabetes (100-125), diabetes (≥126)", lowMeaning: "hypoglycemia" },

  // ── Iron Profile ──
  Iron:              { low: 60,   high: 170,  unit: "µg/dL", highMeaning: "hemochromatosis", lowMeaning: "iron deficiency anemia" },
  TIBC:              { low: 250,  high: 370,  unit: "µg/dL", highMeaning: "iron deficiency", lowMeaning: "chronic disease, hemochromatosis" },
  Transferrin_Saturation: { low: 20, high: 50, unit: "%", highMeaning: "iron overload", lowMeaning: "iron deficiency" },

  // ── Thyroid ──
  TT3:               { low: 80,   high: 200,  unit: "ng/dL", highMeaning: "hyperthyroidism", lowMeaning: "hypothyroidism" },
  TT4:               { low: 5.1,  high: 14.1, unit: "µg/dL", highMeaning: "hyperthyroidism", lowMeaning: "hypothyroidism" },
  TSH:               { low: 0.27, high: 4.2,  unit: "mIU/L", highMeaning: "hypothyroidism", lowMeaning: "hyperthyroidism" },
};

/**
 * Given biomarker stats from the dashboard, annotate each with
 * clinical context (reference range + flag if mean is out of range).
 */
export function annotateWithRanges(
  summary: Record<string, { mean: number | null; std: number | null; min: number | null; max: number | null; n: number }>,
): string {
  const lines: string[] = [];

  for (const [name, stats] of Object.entries(summary)) {
    const ref = CLINICAL_RANGES[name];
    const mean = stats.mean;
    const meanStr = mean !== null && Number.isFinite(mean) ? mean.toFixed(2) : "n/a";
    const minStr = stats.min !== null && Number.isFinite(stats.min) ? stats.min.toFixed(2) : "n/a";
    const maxStr = stats.max !== null && Number.isFinite(stats.max) ? stats.max.toFixed(2) : "n/a";
    const stdStr = stats.std !== null && Number.isFinite(stats.std) ? stats.std.toFixed(2) : "n/a";

    let line = `${name}: mean=${meanStr}, std=${stdStr}, range=[${minStr}, ${maxStr}], n=${stats.n}`;

    if (ref) {
      line += ` | Ref: ${ref.low}–${ref.high} ${ref.unit}`;
      if (mean !== null && Number.isFinite(mean)) {
        if (mean > ref.high) {
          line += ` ⚠ ELEVATED (may indicate: ${ref.highMeaning ?? "unknown"})`;
        } else if (mean < ref.low) {
          line += ` ⚠ LOW (may indicate: ${ref.lowMeaning ?? "unknown"})`;
        } else {
          line += ` ✓ Within normal range`;
        }
      }
    }

    lines.push(line);
  }

  return lines.join("\n");
}

/**
 * Build clinical pattern alerts from summary data.
 * Detects multi-biomarker patterns that are clinically meaningful.
 */
export function detectClinicalPatterns(
  summary: Record<string, { mean: number | null; n: number }>,
): string[] {
  const alerts: string[] = [];
  const val = (name: string) => {
    const s = summary[name];
    return s?.mean !== null && s?.mean !== undefined && Number.isFinite(s.mean) ? s.mean : null;
  };

  // Liver panel pattern
  const alt = val("ALT_SGPT"), ast = val("AST_SGOT"), alp = val("ALP"), ggt = val("GGT");
  if (alt !== null && ast !== null && alt > 56 && ast > 40) {
    alerts.push("⚠ Both ALT and AST elevated — suggests hepatocellular injury. Check for hepatitis, drug toxicity, or fatty liver.");
  }
  if (alp !== null && ggt !== null && alp > 147 && ggt > 65) {
    alerts.push("⚠ Both ALP and GGT elevated — suggests cholestatic pattern. Evaluate for biliary obstruction.");
  }

  // Kidney pattern
  const cr = val("Creatinine"), egfr = val("eGFR"), bun = val("BUN");
  if (cr !== null && egfr !== null && cr > 1.2 && egfr < 60) {
    alerts.push("⚠ Elevated creatinine with low eGFR (<60) — suggests significant renal impairment (CKD stage 3+).");
  }

  // Lipid cardiovascular risk
  const ldl = val("LDL"), hdl = val("HDL"), tg = val("Triglycerides");
  if (ldl !== null && ldl > 130 && hdl !== null && hdl < 40) {
    alerts.push("⚠ High LDL with low HDL — elevated cardiovascular risk profile.");
  }
  if (tg !== null && tg > 200) {
    alerts.push("⚠ Triglycerides >200 — risk of pancreatitis, metabolic syndrome.");
  }

  // Anemia pattern
  const hgb = val("Hemoglobin"), mcv = val("MCV"), iron = val("Iron");
  if (hgb !== null && hgb < 12) {
    if (mcv !== null && mcv < 80) {
      alerts.push("⚠ Low hemoglobin + low MCV — microcytic anemia pattern (consider iron deficiency, thalassemia).");
    } else if (mcv !== null && mcv > 100) {
      alerts.push("⚠ Low hemoglobin + high MCV — macrocytic anemia pattern (consider B12/folate deficiency).");
    } else {
      alerts.push("⚠ Low hemoglobin — anemia detected. Check iron studies and reticulocyte count.");
    }
  }

  // Thyroid pattern
  const tsh = val("TSH"), t3 = val("TT3"), t4 = val("TT4");
  if (tsh !== null && tsh > 4.2) {
    alerts.push("⚠ Elevated TSH — suggests hypothyroidism." + (t4 !== null && t4 < 5.1 ? " Confirmed by low T4." : ""));
  } else if (tsh !== null && tsh < 0.27) {
    alerts.push("⚠ Low TSH — suggests hyperthyroidism." + (t3 !== null && t3 > 200 ? " Confirmed by elevated T3." : ""));
  }

  // Diabetes screening
  const fg = val("Fasting_Glucose");
  if (fg !== null && fg >= 126) {
    alerts.push("⚠ Fasting glucose ≥126 mg/dL — meets diabetes diagnostic threshold.");
  } else if (fg !== null && fg >= 100) {
    alerts.push("⚠ Fasting glucose 100-125 mg/dL — prediabetes range (impaired fasting glucose).");
  }

  return alerts;
}
