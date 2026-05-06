# Pseudocode — Script 2.0 (BigQuery Star Schema)

This document presents the logical pseudocode for every SQL object defined in `Script 2.0.pdf`. Individual SQL scripts are located in `Dataset/Script/{Dimension,Fact,View Fact}/`.

---

## Table of Contents

1. [Dimension Tables](#1-dimension-tables)
2. [Fact Tables](#2-fact-tables)
3. [Analytics Views](#3-analytics-views)
4. [Dashboard Data Loading](#4-dashboard-data-loading)

---

## 1. Dimension Tables

### 1.1 MedID_Dimension

**Script:** `Dataset/Script/Dimension/MedID_Dimension.sql`

```
FUNCTION Build_MedID_Dimension():

    // Step 1: Parse AgeCategories into numeric ranges
    age_ranges = []
    FOR EACH row IN AgeCategories:
        range_text = REPLACE(row.Age_Range, '–', '-')    // normalize dashes
        parts      = SPLIT(range_text, '-')
        age_ranges.APPEND({
            category:  row.Category,
            start_age: INT(parts[0]),
            end_age:   INT(parts[1])
        })

    // Step 2: Enrich each patient with an age category
    result = []
    FOR EACH patient IN MedIDDetails:
        age_cat = 'Unknown'
        FOR EACH range IN age_ranges:
            IF patient.Age BETWEEN range.start_age AND range.end_age:
                age_cat = range.category
                BREAK

        result.APPEND({
            ID:                  AUTO_INCREMENT,
            Original_MedID:      STRING(patient.MedID),
            LabReference:        COALESCE(patient.LabReference, 'Unknown'),
            First_Name:          COALESCE(patient.First_Name,   'Unknown'),
            Last_Name:           COALESCE(patient.Last_Name,    'Unknown'),
            Age:                 COALESCE(patient.Age,           -1),
            Age_Category:        age_cat,
            Gender:              COALESCE(patient.Gender,        'Unknown'),
            Diet:                COALESCE(patient.Diet,          'Unknown'),
            Registration_Weight: COALESCE(patient.Reg_Weight,    0.0)
        })

    RETURN result     // → MedID_Dimension table
```

---

### 1.2 LabReference_Dimension

**Script:** `Dataset/Script/Dimension/LabReference_Dimension.sql`

```
FUNCTION Build_LabReference_Dimension():

    // Collect all unique lab references from BOTH sources
    refs = SET()
    FOR EACH row IN Medical_Records WHERE LabReference IS NOT NULL:
        refs.ADD(row.LabReference)
    FOR EACH row IN MedIDDetails WHERE LabReference IS NOT NULL:
        refs.ADD(row.LabReference)

    // Build dimension with surrogate keys
    result = []
    FOR i, ref IN ENUMERATE(SORTED(refs)):
        result.APPEND({
            ID:           i + 1,
            LabReference: ref
        })

    RETURN result
```

---

### 1.3 SampleID_Dimension

**Script:** `Dataset/Script/Dimension/SampleID_Dimension.sql`

```
FUNCTION Build_SampleID_Dimension():

    sample_ids = DISTINCT(Medical_Records_Cleaned.Sample_ID)
                    .WHERE(NOT NULL)

    result = []
    FOR i, sid IN ENUMERATE(SORTED(sample_ids)):
        result.APPEND({
            ID:        i + 1,
            Sample_ID: STRING(sid)
        })

    RETURN result
```

---

### 1.4 Collected_Dimension

**Script:** `Dataset/Script/Dimension/Collected_Dimension.sql`

```
FUNCTION Build_Collected_Dimension():

    dates = DISTINCT(Medical_Records_Cleaned.Collected)
               .WHERE(NOT NULL)

    result = []
    FOR i, d IN ENUMERATE(SORTED(dates)):
        result.APPEND({
            ID:   i + 1,
            Date: d
        })

    RETURN result
```

---

### 1.5 Time_Dimension

**Script:** `Dataset/Script/Dimension/Time_Dimension.sql`

```
FUNCTION Build_Time_Dimension():

    times = DISTINCT(Medical_Records_Cleaned.Time)
               .WHERE(NOT NULL)

    result = []
    FOR i, t IN ENUMERATE(SORTED(times)):
        result.APPEND({
            ID:   i + 1,
            Time: t
        })

    RETURN result
```

---

### 1.6 Reported_Time_Dimension

**Script:** `Dataset/Script/Dimension/Reported_Time_Dimension.sql`

```
FUNCTION Build_Reported_Time_Dimension():

    times = DISTINCT(Medical_Records_Cleaned.Reported_Time)
               .WHERE(NOT NULL)

    result = []
    FOR i, t IN ENUMERATE(SORTED(times)):
        result.APPEND({
            ID:            i + 1,
            Reported_Time: t
        })

    RETURN result
```

---

## 2. Fact Tables

All fact tables follow a **common template** shown below. The only difference is which measure columns are extracted.

### Common Fact Table Template

```
FUNCTION Build_Fact_<Domain>():

    result = []
    FOR EACH record IN Medical_Records_Cleaned:

        // ── Resolve Foreign Keys ──
        med_fk  = LOOKUP MedID_Dimension     WHERE Original_MedID = STRING(record.MedID)
        lab_fk  = LOOKUP LabReference_Dimension WHERE LabReference = record.LabReference
        samp_fk = LOOKUP SampleID_Dimension  WHERE Sample_ID = STRING(record.Sample_ID)
        coll_fk = LOOKUP Collected_Dimension WHERE Date = record.Collected
        time_fk = LOOKUP Time_Dimension      WHERE Time = record.Time
        rep_fk  = LOOKUP Reported_Time_Dimension WHERE Reported_Time = record.Reported_Time

        // ── Default missing FKs to -1 ──
        med_fk  = COALESCE(med_fk.ID,  -1)
        lab_fk  = COALESCE(lab_fk.ID,  -1)
        samp_fk = COALESCE(samp_fk.ID, -1)
        coll_fk = COALESCE(coll_fk.ID, -1)
        time_fk = COALESCE(time_fk.ID, -1)
        rep_fk  = COALESCE(rep_fk.ID,  -1)

        // ── Extract domain measures (with null defaults) ──
        measures = EXTRACT_MEASURES(record)     // domain-specific

        result.APPEND({
            MedID_FK:          med_fk,
            LabReference_FK:   lab_fk,
            SampleID_FK:       samp_fk,
            Collected_FK:      coll_fk,
            Time_FK:           time_fk,
            Reported_Time_FK:  rep_fk,
            ...measures
        })

    RETURN result
```

---

### 2.1 Fact_Urine — EXTRACT_MEASURES

**Script:** `Dataset/Script/Fact/Fact_Urine.sql`

```
FUNCTION EXTRACT_MEASURES(record):
    RETURN {
        Urine_Colour:    COALESCE(record.Urine_Colour,       'Unknown'),
        Appearance:      COALESCE(record.Appearance,          'Unknown'),
        Specific_Gravity: COALESCE(record.Specific_Gravity,   0.0),
        pH:              COALESCE(record.pH,                  0.0),
        Proteins:        COALESCE(record.Proteins,            'Unknown'),
        Glucose:         COALESCE(record.Glucose,             'Unknown'),
        Bilirubin:       COALESCE(record.Bilirubin,           'Unknown'),
        Ketones:         COALESCE(record.Ketones,             'Unknown'),
        Blood:           COALESCE(record.Blood,               'Unknown'),
        Urobilinogen:    COALESCE(record.Urobilinogen,        'Unknown'),
        Nitrites:        COALESCE(record.Nitrites,            'Unknown'),
        WBC_Pus_Cells:   COALESCE(record.WBC_Pus_Cells,      'Unknown'),
        RBC:             COALESCE(record.RBC,                 'Unknown'),
        Epithelial_Cells: COALESCE(record.Epithelial_Cells,   'Unknown'),
        Casts:           COALESCE(record.Casts,               'Unknown'),
        Crystals:        COALESCE(record.Crystals,            'Unknown'),
        Others:          COALESCE(record.Others,              'Unknown')
    }
```

---

### 2.2 Fact_CBC — EXTRACT_MEASURES

**Script:** `Dataset/Script/Fact/Fact_CBC.sql`

```
FUNCTION EXTRACT_MEASURES(record):
    RETURN {
        Hemoglobin:       COALESCE(record.Hemoglobin,        0.0),
        RBC_Count:        COALESCE(record.RBC_Count,         0.0),
        Hematocrit:       COALESCE(record.Hematocrit,        0.0),
        MCV:              COALESCE(record.MCV,               0.0),
        MCH:              COALESCE(record.MCH,               0),
        MCHC:             COALESCE(record.MCHC,              0.0),
        RDW_CV:           COALESCE(record.RDW_CV,            0.0),
        RDW_SD:           COALESCE(record.RDW_SD,            0.0),
        WBC_Count:        COALESCE(record.WBC_Count,         0),
        Neutrophils:      COALESCE(record.Neutrophils_Pct,   0),
        Lymphocytes:      COALESCE(record.Lymphocytes_Pct,   0),
        Eosinophils:      COALESCE(record.Eosinophils_Pct,   0),
        Monocytes:        COALESCE(record.Monocytes_Pct,     0),
        Basophils:        COALESCE(record.Basophils_Pct,     0.0),
        Abs_Neutrophils:  COALESCE(record.Abs_Neutrophils,   0.0),
        Abs_Lymphocytes:  COALESCE(record.Abs_Lymphocytes,   0.0),
        Abs_Monocytes:    COALESCE(record.Abs_Monocytes,     0.0),
        Abs_Eosinophils:  COALESCE(record.Abs_Eosinophils,   0.0),
        Abs_Basophils:    COALESCE(record.Abs_Basophils,     0.0)
    }
```

---

### 2.3 Fact_Platelet_Profile — EXTRACT_MEASURES

**Script:** `Dataset/Script/Fact/Fact_Platelet_Profile.sql`

```
FUNCTION EXTRACT_MEASURES(record):
    RETURN {
        Platelet_Count: COALESCE(record.Platelet_Count, 0),
        MPV:            COALESCE(record.MPV,            0.0),
        Platelet_RDW:   COALESCE(record.Platelet_RDW,  0),
        PCT:            COALESCE(record.PCT,            0.0),
        P_LCR:          COALESCE(record.P_LCR,         0.0),
        IMG:            COALESCE(record.IMG,            0.0),
        IMM:            COALESCE(record.IMM,            0.0),
        IML:            COALESCE(record.IML,            0.0),
        LIC:            COALESCE(record.LIC,            0.0)
    }
```

---

### 2.4 Fact_Lipid_Profile — EXTRACT_MEASURES

**Script:** `Dataset/Script/Fact/Fact_Lipid_Profile.sql`

```
FUNCTION EXTRACT_MEASURES(record):
    RETURN {
        Total_Cholesterol: COALESCE(record.Total_Cholesterol, 0),
        HDL:               COALESCE(record.HDL,               0),
        LDL:               COALESCE(record.LDL,               0.0),
        VLDL:              COALESCE(record.VLDL,              'Unknown'),  // STRING
        Triglycerides:     COALESCE(record.Triglycerides,     'Unknown'),  // STRING
        Non_HDL:           COALESCE(record.Non_HDL,           0),
        Total_HDL_Ratio:   COALESCE(record.Total_HDL_Ratio,  0.0),
        LDL_HDL_Ratio:     COALESCE(record.LDL_HDL_Ratio,   0.0),
        HDL_LDL_Ratio:     COALESCE(record.HDL_LDL_Ratio,   0.0)
    }
    // NOTE: VLDL and Triglycerides kept as STRING to match source.
    //       Converted to FLOAT64 in the View layer via SAFE_CAST().
```

---

### 2.5 Fact_Liver_Function — EXTRACT_MEASURES

**Script:** `Dataset/Script/Fact/Fact_Liver Function.sql`

```
FUNCTION EXTRACT_MEASURES(record):
    RETURN {
        Bilirubin_Total:    COALESCE(record.Bilirubin_Total,    0.0),
        Bilirubin_Direct:   COALESCE(record.Bilirubin_Direct,   0.0),
        Bilirubin_Indirect: COALESCE(record.Bilirubin_Indirect, 0.0),
        ALP:                COALESCE(record.ALP,                0),
        ALT_SGPT:           COALESCE(record.ALT_SGPT,          0),
        AST_SGOT:           COALESCE(record.AST_SGOT,          0),
        GGT:                COALESCE(record.GGT,               0),
        Protein_Total:      COALESCE(record.Protein_Total,     0.0),
        Albumin:            COALESCE(record.Albumin,           0.0),
        Globulin:           COALESCE(record.Globulin,          0.0),
        A_G_Ratio:          SAFE_CAST(COALESCE(record.A_G_Ratio, '0') AS FLOAT)
    }
    // NOTE: A/G Ratio is STRING in source; SAFE_CAST converts it.
```

---

### 2.6 Fact_Kidney_Function — EXTRACT_MEASURES

**Script:** `Dataset/Script/Fact/Fact_Kidney_Function.sql`

```
FUNCTION EXTRACT_MEASURES(record):
    RETURN {
        Creatinine:          COALESCE(record.Creatinine,          0.0),
        Urea:                COALESCE(record.Urea,                0.0),
        BUN:                 COALESCE(record.BUN,                 0.0),
        BUN_Creatinine_Ratio: COALESCE(record.BUN_Creatinine,    0.0),
        Sodium:              COALESCE(record.Sodium,              0),
        Potassium:           COALESCE(record.Potassium,           0.0),
        Chloride:            COALESCE(record.Chloride,            0),
        Uric_Acid:           COALESCE(record.Uric_Acid,          0.0),
        eGFR:                COALESCE(record.eGFR,               0.0)
    }
```

---

### 2.7 Fact_Iron_Profile — EXTRACT_MEASURES

**Script:** `Dataset/Script/Fact/Fact_Iron_Profile.sql`

```
FUNCTION EXTRACT_MEASURES(record):
    RETURN {
        Iron:                    COALESCE(record.Iron,                  0),
        UIBC:                    COALESCE(record.UIBC,                 0),
        TIBC:                    COALESCE(record.TIBC,                 0),
        Transferrin_Saturation:  COALESCE(record.Transferrin_Sat,      0.0)
    }
```

---

### 2.8 Fact_HbA1c — EXTRACT_MEASURES

**Script:** `Dataset/Script/Fact/Fact_HbA1c.sql`

```
FUNCTION EXTRACT_MEASURES(record):
    RETURN {
        HbA1c:               COALESCE(record.HbA1c,              0.0),
        Estimated_Avg_Glucose: COALESCE(record.Est_Avg_Glucose,  0.0),
        HbF:                 COALESCE(record.HbF,                0.0)
    }
```

---

### 2.9 Fact_Urine_ACR — EXTRACT_MEASURES

**Script:** `Dataset/Script/Fact/Fact_Urine_ACR.sql`

```
FUNCTION EXTRACT_MEASURES(record):
    RETURN {
        Urine_Albumin:            COALESCE(record.Urine_Albumin,         0.0),
        Urine_Creatinine:         COALESCE(record.Urine_Creatinine,      0.0),
        Albumin_Creatinine_Ratio: COALESCE(record.Alb_Creat_Ratio,       0.0)
    }
```

---

### 2.10 Fact_Calcium_Phos — EXTRACT_MEASURES

**Script:** `Dataset/Script/Fact/Fact_Calcium_Phos.sql`

```
FUNCTION EXTRACT_MEASURES(record):
    RETURN {
        Calcium:    COALESCE(record.Calcium,    0.0),
        Phosphorus: COALESCE(record.Phosphorus, 0.0)
    }
```

---

### 2.11 Fact_Thyroid_Profile — EXTRACT_MEASURES

**Script:** `Dataset/Script/Fact/Fact_Thyroid_Profile.sql`

```
FUNCTION EXTRACT_MEASURES(record):
    RETURN {
        TT3: COALESCE(record.TT3, 0),       // INT
        TT4: COALESCE(record.TT4, 0.0),     // FLOAT
        TSH: COALESCE(record.TSH, 0.0)      // FLOAT
    }
```

---

### 2.12 Fact_Glucose_Fasting — EXTRACT_MEASURES

**Script:** `Dataset/Script/Fact/Fact_Glucose_Fasting.sql`

```
FUNCTION EXTRACT_MEASURES(record):
    RETURN {
        Fasting_Glucose: COALESCE(record.Fasting_Glucose, 0)   // INT
    }
```

---

### 2.13 Fact_Glucose_PP — EXTRACT_MEASURES

**Script:** `Dataset/Script/Fact/Fact_Glucose_PP.sql`

```
FUNCTION EXTRACT_MEASURES(record):
    RETURN {
        Postprandial_Glucose: COALESCE(record.Postprandial_Glucose, 0)  // INT
    }
```

---

### 2.14 Fact_Glucose_Diagnopath — EXTRACT_MEASURES

**Script:** `Dataset/Script/Fact/Fact_Glucose_Diagnopath.sql`

```
FUNCTION EXTRACT_MEASURES(record):
    RETURN {
        FBS:  COALESCE(record.FBS,  0),    // Fasting Blood Sugar (INT)
        PLBS: COALESCE(record.PLBS, 0)     // Post-Lunch Blood Sugar (INT)
    }
```

---

## 3. Analytics Views

All views follow a **single common pattern**. The only difference is which fact table they read from and which measure columns they expose.

### Common View Template

```
FUNCTION Build_View_Fact_<Domain>():

    result = []
    FOR EACH fact_row IN Fact_<Domain>:

        // ── Resolve patient info ──
        patient = LOOKUP MedID_Dimension WHERE ID = fact_row.MedID_FK

        // ── Resolve test date ──
        date_row = LOOKUP Collected_Dimension WHERE ID = fact_row.Collected_FK

        // ── Build flat output row ──
        row = {
            Original_MedID: IFNULL(patient.Original_MedID, 'Unknown'),
            First_Name:     IFNULL(patient.First_Name,     'Unknown'),
            Last_Name:      IFNULL(patient.Last_Name,      'Unknown'),
            Gender:         IFNULL(patient.Gender,          'Unknown'),
            Age_Category:   IFNULL(patient.Age_Category,   'Unknown'),
            Test_Date:      IFNULL(date_row.Date,          '1970-01-01'),
            ...APPLY_IFNULL_TO_ALL_MEASURES(fact_row)
        }

        result.APPEND(row)

    RETURN result    // live (non-materialized) view
```

### View-Specific Measure Handling

| View | Special Logic |
|---|---|
| `View_Fact_Urine` | STRING measures default to `'N/A'` instead of `'Unknown'` |
| `View_Fact_Lipid_Profile` | `SAFE_CAST(VLDL AS FLOAT)`, `SAFE_CAST(Triglycerides AS FLOAT)` |
| All others | Standard `IFNULL(measure, 0)` or `IFNULL(measure, 0.0)` |

---

## 4. Dashboard Data Loading

When connected to the Healthcare Dashboard, the views are consumed as follows:

```
FUNCTION Dashboard_Load_Data():

    // 1. Read BIGQUERY_VIEW_NAMES from .env.local
    //    → all 14 View_Fact_* view names (comma-separated)
    viewNames = PARSE_ENV("BIGQUERY_VIEW_NAMES")

    // 2. For each view, discover numeric columns via INFORMATION_SCHEMA
    FOR EACH view IN viewNames:
        columns = QUERY BigQuery INFORMATION_SCHEMA.COLUMNS
                    WHERE table_name = view
                      AND data_type IN ('INT64', 'FLOAT64', 'NUMERIC')
        EXCLUDE patient/date/name columns

    // 3. Build UNPIVOT SQL for each view (wide → long format)
    FOR EACH view IN viewNames:
        branch = SELECT Original_MedID AS patient_id,
                        Test_Date AS visit_date,
                        biomarker, value, view AS group
                 FROM view
                 UNPIVOT(value FOR biomarker IN (col1, col2, ...))
                 WHERE Test_Date BETWEEN dateFrom AND dateTo

    // 4. UNION ALL branches → single stream of BiomarkerRow[]
    sql = UNION_ALL(branches) ORDER BY visit_date LIMIT rowLimit

    // 5. Execute and return
    RETURN BiomarkerRow[] { patient_id, visit_date, biomarker, value, group }
```

---

## Data Flow Summary

```
┌──────────────────┐
│   CSVs Uploaded  │
│   to BigQuery    │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐     ┌───────────────────────┐
│ Build 6 Dimension│────►│ Surrogate Key Lookup  │
│ Tables           │     │ Tables Ready          │
└────────┬─────────┘     └───────────┬───────────┘
         │                           │
         ▼                           ▼
┌──────────────────┐     ┌───────────────────────┐
│ Build 14 Fact    │────►│ FK Resolution via     │
│ Tables           │     │ LEFT JOIN → COALESCE  │
└────────┬─────────┘     └───────────────────────┘
         │
         ▼
┌──────────────────┐     ┌───────────────────────┐
│ Create 14 Views  │────►│ Flat, null-safe,      │
│ (non-materialized│     │ dashboard-ready       │
│  live queries)   │     │ output for BI tools   │
└────────┬─────────┘     └───────────────────────┘
         │
         ▼
┌──────────────────┐     ┌───────────────────────┐
│ Dashboard loads  │────►│ UNPIVOT + UNION ALL   │
│ via bigquery.ts  │     │ → BiomarkerRow[]      │
└──────────────────┘     └───────────────────────┘
```
