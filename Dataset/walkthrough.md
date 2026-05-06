# Walkthrough — Medical Records Data Warehouse Build

This document walks through the entire `Script 2.0.pdf` execution pipeline, explaining **what each SQL statement does**, **why**, and **in what order** to run them on BigQuery.

---

## Prerequisites

| Requirement | Details |
|---|---|
| BigQuery Project | `bigquery-tutorial-480009` |
| Dataset | `A2` |
| Source tables | `AgeCategories`, `MedIDDetails`, `Medical_Records_Cleaned` (pre-loaded from CSVs) |

> [!IMPORTANT]
> The script references `Medical_Records_Cleaned` (not the raw CSV). This implies a prior cleaning step was applied to `Medical Records.csv` — parsing date/time columns, handling encoding issues, and resolving column-name special characters.

---

## SQL Script Organization

The SQL statements are available in two forms:

1. **Consolidated PDF** — `Script 2.0.pdf` (58 pages, all statements in order)
2. **Individual SQL files** — organized in `Dataset/Script/`:

```
Dataset/Script/
├── Dimension/               # Phase 1 — run first
│   ├── MedID_Dimension.sql
│   ├── LabReference_Dimension.sql
│   ├── SampleID_Dimension.sql
│   ├── Collected_Dimension.sql
│   ├── Time_Dimension.sql
│   └── Reported_Time_Dimension.sql
├── Fact/                    # Phase 2 — run after dimensions
│   ├── Fact_Urine.sql
│   ├── Fact_CBC.sql
│   ├── Fact_Platelet_Profile.sql
│   ├── Fact_Lipid_Profile.sql
│   ├── Fact_Liver Function.sql
│   ├── Fact_Kidney_Function.sql
│   ├── Fact_Iron_Profile.sql
│   ├── Fact_HbA1c.sql
│   ├── Fact_Urine_ACR.sql
│   ├── Fact_Calcium_Phos.sql
│   ├── Fact_Thyroid_Profile.sql
│   ├── Fact_Glucose_Fasting.sql
│   ├── Fact_Glucose_PP.sql
│   └── Fact_Glucose_Diagnopath.sql
└── View Fact/               # Phase 3 — run after facts
    ├── View_Fact_Urine.sql
    ├── View_Fact_CBC.sql
    ├── View_Fact_Platet_Profile.sql
    ├── View_Fact_Lipid_Profile.sql
    ├── View_Fact_Liver_Function.sql
    ├── View_Fact_Kidney_Function.sql
    ├── View_Fact_Iron_Profile.sql
    ├── View_Fact_HbA1c.sql
    ├── View_Fact_Urine_ACR.sql
    ├── View_Fact_Calcium_Phos.sql
    ├── View_Fact_Thyroid_Profile.sql
    ├── View_Fact_Glucose_Fasting.sql
    ├── View_Fact_Glucose_PP.sql
    └── View_Fact_Glucose_Diagnopath.sql
```

---

## Phase 1 — Dimension Tables (Pages 3–9)

Dimensions are the **lookup/reference tables** that describe the "who/when/where" of each lab test. They must be built **before** the fact tables because facts reference them via foreign keys.

### Step 1.1 — MedID_Dimension (Pages 3–4)

**Script:** `Dataset/Script/Dimension/MedID_Dimension.sql`

**What it does:**
- Reads every row from `MedIDDetails` (patient demographics).
- LEFT JOINs to a CTE built from `AgeCategories` to assign an `Age_Category` label (e.g., "Career Growth" for ages 35–39).
- Generates a surrogate `ID` via `ROW_NUMBER()`.
- Handles `Zender` → `Gender` mapping and null-coalescing to `'Unknown'` / `0.0` / `-1`.

**Output:** One row per patient. Columns: `ID`, `Original_MedID`, `LabReference`, `First_Name`, `Last_Name`, `Age`, `Age_Category`, `Gender`, `Diet`, `Registration_Weight`.

### Step 1.2 — LabReference_Dimension (Page 5)

**Script:** `Dataset/Script/Dimension/LabReference_Dimension.sql`

**What it does:**
- Collects all unique `LabReference` codes from **both** `Medical_Records` and `MedIDDetails` (UNION DISTINCT).
- Generates surrogate IDs.

**Why union both?** A lab reference might appear in patient details but not in test records, or vice versa. The union ensures full coverage.

### Step 1.3 — SampleID_Dimension (Page 6)

**Script:** `Dataset/Script/Dimension/SampleID_Dimension.sql`

**What it does:**
- Extracts distinct `Sample ID` values from the cleaned records.
- Casts to STRING and assigns sequential IDs.

### Step 1.4 — Collected_Dimension (Page 7)

**Script:** `Dataset/Script/Dimension/Collected_Dimension.sql`

**What it does:**
- Extracts distinct collection dates.
- Assigns sequential IDs ordered by date.

### Step 1.5 — Time_Dimension (Page 8)

**Script:** `Dataset/Script/Dimension/Time_Dimension.sql`

**What it does:**
- Extracts distinct collection times (TIME type).
- Assigns sequential IDs.

### Step 1.6 — Reported_Time_Dimension (Page 9)

**Script:** `Dataset/Script/Dimension/Reported_Time_Dimension.sql`

**What it does:**
- Same pattern as Time_Dimension, but for the "Reported Time" (when the lab result was reported).

---

## Phase 2 — Fact Tables (Pages 10–37)

Each fact table extracts a **domain-specific subset** of the 96-column `Medical_Records_Cleaned` table and links it to all 6 dimensions via LEFT JOINs.

All fact tables share a **common pattern**:

```
CREATE OR REPLACE TABLE ... (
    -- 6 Foreign Key columns (INT64 NOT NULL)
    -- Domain-specific measure columns
)
AS
SELECT
    COALESCE(d_med.ID, -1)  AS MedID_FK,
    COALESCE(d_lab.ID, -1)  AS LabReference_FK,
    COALESCE(d_samp.ID, -1) AS SampleID_FK,
    COALESCE(d_coll.ID, -1) AS Collected_FK,
    COALESCE(d_time.ID, -1) AS Time_FK,
    COALESCE(d_rep.ID, -1)  AS Reported_Time_FK,
    -- measure columns with COALESCE defaults
FROM Medical_Records_Cleaned f
LEFT JOIN MedID_Dimension      ON CAST(f.MedID AS STRING) = Original_MedID
LEFT JOIN LabReference_Dimension ON ...
LEFT JOIN SampleID_Dimension    ON ...
LEFT JOIN Collected_Dimension   ON ...
LEFT JOIN Time_Dimension        ON ...
LEFT JOIN Reported_Time_Dimension ON ...
```

### Step 2.1 — Fact_Urine (Pages 10–11)

**Script:** `Dataset/Script/Fact/Fact_Urine.sql`

**17 measures:** Urine Colour, Appearance, Specific Gravity, pH, Proteins, Glucose, Bilirubin, Ketones, Blood, Urobilinogen, Nitrites, WBC/Pus Cells, RBC, Epithelial Cells, Casts, Crystals, Others.

**Note:** Most urine measures are STRING type (semiquantitative results like "Negative", "Trace", "2+").

### Step 2.2 — Fact_CBC (Pages 12–13)

**Script:** `Dataset/Script/Fact/Fact_CBC.sql`

**19 measures:** Hemoglobin, RBC Count, Hematocrit, MCV, MCH, MCHC, RDW-CV, RDW-SD, WBC Count, Neutrophils %, Lymphocytes %, Eosinophils %, Monocytes %, Basophils %, and 5 absolute counts.

### Step 2.3 — Fact_Platelet_Profile (Pages 14–15)

**Script:** `Dataset/Script/Fact/Fact_Platelet_Profile.sql`

**9 measures:** Platelet Count, MPV, Platelet RDW, PCT, P-LCR, IMG, IMM, IML, LIC.

### Step 2.4 — Fact_Lipid_Profile (Pages 16–17)

**Script:** `Dataset/Script/Fact/Fact_Lipid_Profile.sql`

**9 measures:** Total Cholesterol, HDL, LDL, VLDL, Triglycerides, Non-HDL, Total/HDL Ratio, LDL/HDL Ratio, HDL/LDL Ratio.

> [!NOTE]
> VLDL and Triglycerides are stored as **STRING** in the fact table (matching source schema). They are cast to FLOAT64 in the view layer using `SAFE_CAST()`.

### Step 2.5 — Fact_Liver_Function (Pages 18–19)

**Script:** `Dataset/Script/Fact/Fact_Liver Function.sql`

**11 measures:** Bilirubin (Total, Direct, Indirect), ALP, ALT/SGPT, AST/SGOT, GGT, Protein Total, Albumin, Globulin, A/G Ratio.

> [!NOTE]
> The A/G Ratio is converted from STRING to FLOAT64 using `SAFE_CAST()` during fact table creation.

### Step 2.6 — Fact_Kidney_Function (Pages 20–21)

**Script:** `Dataset/Script/Fact/Fact_Kidney_Function.sql`

**9 measures:** Creatinine, Urea, BUN, BUN/Creatinine Ratio, Sodium, Potassium, Chloride, Uric Acid, eGFR.

### Step 2.7 — Fact_Iron_Profile (Pages 22–23)

**Script:** `Dataset/Script/Fact/Fact_Iron_Profile.sql`

**4 measures:** Iron, UIBC, TIBC, Transferrin Saturation.

### Step 2.8 — Fact_HbA1c (Pages 24–25)

**Script:** `Dataset/Script/Fact/Fact_HbA1c.sql`

**3 measures:** HbA1c %, Estimated Average Glucose, HbF %.

### Step 2.9 — Fact_Urine_ACR (Pages 26–27)

**Script:** `Dataset/Script/Fact/Fact_Urine_ACR.sql`

**3 measures:** Urine Albumin, Urine Creatinine, Albumin/Creatinine Ratio.

### Step 2.10 — Fact_Calcium_Phos (Pages 28–29)

**Script:** `Dataset/Script/Fact/Fact_Calcium_Phos.sql`

**2 measures:** Calcium, Phosphorus.

### Step 2.11 — Fact_Thyroid_Profile (Pages 30–31)

**Script:** `Dataset/Script/Fact/Fact_Thyroid_Profile.sql`

**3 measures:** TT3 (ng/dL), TT4 (µg/dL), TSH (µIU/mL).

### Step 2.12 — Fact_Glucose_Fasting (Pages 32–33)

**Script:** `Dataset/Script/Fact/Fact_Glucose_Fasting.sql`

**1 measure:** Fasting Glucose (mg/dL).

### Step 2.13 — Fact_Glucose_PP (Pages 34–35)

**Script:** `Dataset/Script/Fact/Fact_Glucose_PP.sql`

**1 measure:** Postprandial Glucose (mg/dL).

### Step 2.14 — Fact_Glucose_Diagnopath (Pages 36–37)

**Script:** `Dataset/Script/Fact/Fact_Glucose_Diagnopath.sql`

**2 measures:** FBS (Fasting Blood Sugar), PLBS (Post-Lunch Blood Sugar).

---

## Phase 3 — Analytics Views (Pages 38–51)

Views are **non-materialized, live queries** that denormalize fact + dimension data into flat, dashboard-ready tables. Each view joins the fact table to `MedID_Dimension` (for patient info) and `Collected_Dimension` (for test date).

All views share a **common SELECT header:**

```sql
SELECT
    IFNULL(P.Original_MedID, 'Unknown')   AS Original_MedID,
    IFNULL(P.First_Name, 'Unknown')        AS First_Name,
    IFNULL(P.Last_Name, 'Unknown')         AS Last_Name,
    IFNULL(P.Gender, 'Unknown')            AS Gender,
    IFNULL(P.Age_Category, 'Unknown')      AS Age_Category,
    IFNULL(D.Date, DATE('1970-01-01'))     AS Test_Date,
    -- ... domain metrics ...
FROM Fact_<Domain> F
JOIN MedID_Dimension P      ON F.MedID_FK = P.ID
JOIN Collected_Dimension D  ON F.Collected_FK = D.ID;
```

### Views Created

| # | View Name | Source Fact | Script | Metrics |
|---|---|---|---|---|
| 1 | `View_Fact_Urine` | Fact_Urine | `View Fact/View_Fact_Urine.sql` | 17 urine analysis fields |
| 2 | `View_Fact_CBC` | Fact_CBC | `View Fact/View_Fact_CBC.sql` | 19 blood count metrics |
| 3 | `View_Fact_Platelet_Profile` | Fact_Platelet_Profile | `View Fact/View_Fact_Platet_Profile.sql` | 9 platelet metrics |
| 4 | `View_Fact_Lipid_Profile` | Fact_Lipid_Profile | `View Fact/View_Fact_Lipid_Profile.sql` | 9 cholesterol metrics (VLDL/Trig cast to FLOAT64) |
| 5 | `View_Fact_Liver_Function` | Fact_Liver_Function | `View Fact/View_Fact_Liver_Function.sql` | 11 liver metrics |
| 6 | `View_Fact_Kidney_Function` | Fact_Kidney_Function | `View Fact/View_Fact_Kidney_Function.sql` | 9 kidney/electrolyte metrics |
| 7 | `View_Fact_Iron_Profile` | Fact_Iron_Profile | `View Fact/View_Fact_Iron_Profile.sql` | 4 iron metrics |
| 8 | `View_Fact_HbA1c` | Fact_HbA1c | `View Fact/View_Fact_HbA1c.sql` | 3 glycated hemoglobin metrics |
| 9 | `View_Fact_Urine_ACR` | Fact_Urine_ACR | `View Fact/View_Fact_Urine_ACR.sql` | 3 microalbuminuria metrics |
| 10 | `View_Fact_Calcium_Phos` | Fact_Calcium_Phos | `View Fact/View_Fact_Calcium_Phos.sql` | 2 mineral metrics |
| 11 | `View_Fact_Thyroid_Profile` | Fact_Thyroid_Profile | `View Fact/View_Fact_Thyroid_Profile.sql` | 3 thyroid hormone metrics |
| 12 | `View_Fact_Glucose_Fasting` | Fact_Glucose_Fasting | `View Fact/View_Fact_Glucose_Fasting.sql` | 1 fasting glucose metric |
| 13 | `View_Fact_Glucose_PP` | Fact_Glucose_PP | `View Fact/View_Fact_Glucose_PP.sql` | 1 postprandial glucose metric |
| 14 | `View_Fact_Glucose_Diagnopath` | Fact_Glucose_Diagnopath | `View Fact/View_Fact_Glucose_Diagnopath.sql` | 2 diagnopath glucose metrics |

---

## Phase 4 — Schema Reference (Pages 52–58)

The final section of the PDF documents the **exact column names and data types** for every table, serving as the definitive schema reference.

---

## Phase 5 — Dashboard Integration

Once the views are created in BigQuery, configure the Healthcare Dashboard to load data from them:

1. **Set environment variables** in `.env.local`:
   ```
   BIGQUERY_VIEW_NAMES=View_Fact_Urine,View_Fact_CBC,View_Fact_Platelet_Profile,View_Fact_Lipid_Profile,View_Fact_Liver_Function,View_Fact_Kidney_Function,View_Fact_Iron_Profile,View_Fact_HbA1c,View_Fact_Urine_ACR,View_Fact_Calcium_Phos,View_Fact_Thyroid_Profile,View_Fact_Glucose_Fasting,View_Fact_Glucose_PP,View_Fact_Glucose_Diagnopath
   BQ_COL_PATIENT_ID=Original_MedID
   BQ_COL_VISIT_DATE=Test_Date
   ```

2. **How the dashboard queries views**: The `bigquery.ts` module discovers numeric columns from each view via `INFORMATION_SCHEMA.COLUMNS`, builds an `UNPIVOT` SQL branch for each, and combines them with `UNION ALL` — producing a unified stream of `BiomarkerRow[]` (patient_id, visit_date, biomarker, value, group).

3. **Biomarker groups**: Each row is tagged with `group = viewName`, allowing the dashboard to organize biomarkers by clinical domain (CBC, Liver, Kidney, etc.) in the sidebar filter panel.

---

## Execution Order Summary

```
 Step │  SQL Object                        │  Type       │  Script Location
──────┼────────────────────────────────────┼─────────────┼────────────────────────────
  1   │  MedID_Dimension                   │  Dimension  │  Dimension/MedID_Dimension.sql
  2   │  LabReference_Dimension            │  Dimension  │  Dimension/LabReference_Dimension.sql
  3   │  SampleID_Dimension                │  Dimension  │  Dimension/SampleID_Dimension.sql
  4   │  Collected_Dimension               │  Dimension  │  Dimension/Collected_Dimension.sql
  5   │  Time_Dimension                    │  Dimension  │  Dimension/Time_Dimension.sql
  6   │  Reported_Time_Dimension           │  Dimension  │  Dimension/Reported_Time_Dimension.sql
  7   │  Fact_Urine                        │  Fact       │  Fact/Fact_Urine.sql
  8   │  Fact_CBC                          │  Fact       │  Fact/Fact_CBC.sql
  9   │  Fact_Platelet_Profile             │  Fact       │  Fact/Fact_Platelet_Profile.sql
 10   │  Fact_Lipid_Profile                │  Fact       │  Fact/Fact_Lipid_Profile.sql
 11   │  Fact_Liver_Function               │  Fact       │  Fact/Fact_Liver Function.sql
 12   │  Fact_Kidney_Function              │  Fact       │  Fact/Fact_Kidney_Function.sql
 13   │  Fact_Iron_Profile                 │  Fact       │  Fact/Fact_Iron_Profile.sql
 14   │  Fact_HbA1c                        │  Fact       │  Fact/Fact_HbA1c.sql
 15   │  Fact_Urine_ACR                    │  Fact       │  Fact/Fact_Urine_ACR.sql
 16   │  Fact_Calcium_Phos                 │  Fact       │  Fact/Fact_Calcium_Phos.sql
 17   │  Fact_Thyroid_Profile              │  Fact       │  Fact/Fact_Thyroid_Profile.sql
 18   │  Fact_Glucose_Fasting              │  Fact       │  Fact/Fact_Glucose_Fasting.sql
 19   │  Fact_Glucose_PP                   │  Fact       │  Fact/Fact_Glucose_PP.sql
 20   │  Fact_Glucose_Diagnopath           │  Fact       │  Fact/Fact_Glucose_Diagnopath.sql
 21   │  View_Fact_Urine                   │  View       │  View Fact/View_Fact_Urine.sql
 22   │  View_Fact_CBC                     │  View       │  View Fact/View_Fact_CBC.sql
 23   │  View_Fact_Platelet_Profile        │  View       │  View Fact/View_Fact_Platet_Profile.sql
 24   │  View_Fact_Lipid_Profile           │  View       │  View Fact/View_Fact_Lipid_Profile.sql
 25   │  View_Fact_Liver_Function          │  View       │  View Fact/View_Fact_Liver_Function.sql
 26   │  View_Fact_Kidney_Function         │  View       │  View Fact/View_Fact_Kidney_Function.sql
 27   │  View_Fact_Iron_Profile            │  View       │  View Fact/View_Fact_Iron_Profile.sql
 28   │  View_Fact_HbA1c                   │  View       │  View Fact/View_Fact_HbA1c.sql
 29   │  View_Fact_Urine_ACR              │  View       │  View Fact/View_Fact_Urine_ACR.sql
 30   │  View_Fact_Calcium_Phos            │  View       │  View Fact/View_Fact_Calcium_Phos.sql
 31   │  View_Fact_Thyroid_Profile         │  View       │  View Fact/View_Fact_Thyroid_Profile.sql
 32   │  View_Fact_Glucose_Fasting         │  View       │  View Fact/View_Fact_Glucose_Fasting.sql
 33   │  View_Fact_Glucose_PP              │  View       │  View Fact/View_Fact_Glucose_PP.sql
 34   │  View_Fact_Glucose_Diagnopath      │  View       │  View Fact/View_Fact_Glucose_Diagnopath.sql
```

---

## Post-Deployment

Once all 34 SQL objects are created:

1. **Validate row counts** — Each fact table should have ~13,849 rows (matching `Medical_Records_Cleaned`).
2. **Verify FK integrity** — Check that no foreign keys resolved to `-1` (orphaned records).
3. **Connect the Healthcare Dashboard** — Set `BIGQUERY_VIEW_NAMES` to all 14 `View_Fact_*` names in `.env.local` and run `npm run dev`.
4. **Connect BI tools** — Point Looker Studio / Tableau / Power BI to the `View_Fact_*` views for filtered, null-safe analytics.
5. **Sample query:**

```sql
SELECT Gender, Age_Category, AVG(Hemoglobin) AS Avg_Hemoglobin
FROM `bigquery-tutorial-480009.A2.View_Fact_CBC`
GROUP BY Gender, Age_Category
ORDER BY Avg_Hemoglobin DESC;
```
