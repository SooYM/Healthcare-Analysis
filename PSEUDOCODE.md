# Pseudocode & System Walkthrough

> A plain-English explanation of every module in the Healthcare Dashboard, how they connect, and the data flow from BigQuery to the browser.

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [Data Flow Diagram](#2-data-flow-diagram)
3. [Types & Data Shapes](#3-types--data-shapes)
4. [Environment & Configuration](#4-environment--configuration)
5. [API Routes](#5-api-routes)
6. [Library Modules](#6-library-modules)
7. [Frontend Components](#7-frontend-components)
8. [AI Explanation Pipeline](#8-ai-explanation-pipeline)
9. [OLAP Cube Engine](#9-olap-cube-engine)
10. [Included Dataset & BigQuery Star Schema](#10-included-dataset--bigquery-star-schema)

---

## 1. System Overview

```
┌─────────────────────────────────────────────────────────┐
│                     BROWSER (React)                     │
│  Dashboard.tsx  ←→  OlapCube.tsx  ←→  PageTransition    │
│       ↕ fetch            ↕ fetch                        │
├─────────────────────────────────────────────────────────┤
│                  NEXT.JS API LAYER                       │
│  /api/data    /api/explain    /api/patients   /api/health│
├─────────────────────────────────────────────────────────┤
│                  SERVER-SIDE LIBS                        │
│  bigquery.ts   openai.ts   huggingface.ts   gemini.ts   │
│  stats.ts      clinical-ranges.ts   demo-data.ts        │
│  env.ts        vertex.ts                                │
├─────────────────────────────────────────────────────────┤
│              EXTERNAL SERVICES                           │
│  Google BigQuery    Google Gemini API    HuggingFace     │
│  OpenAI GPT         Vertex AI (optional)                │
├─────────────────────────────────────────────────────────┤
│              INCLUDED DATASET (Dataset/)                 │
│  3 CSVs  →  6 Dimensions  →  14 Facts  →  14 Views     │
│  SQL scripts in Dataset/Script/{Dimension,Fact,View Fact}│
└─────────────────────────────────────────────────────────┘
```

---

## 2. Data Flow Diagram

```
USER opens page
  │
  ├─► Browser auto-fetches GET /api/patients
  │     └─► Returns list of patient IDs (from BigQuery or demo)
  │
  └─► Browser auto-fetches POST /api/data  { dateFrom, dateTo, rowLimit }
        │
        ├─ IF demo mode OR no GCP credentials:
        │     └─► generateDemoRows() → synthetic data
        │
        └─ ELSE (BigQuery configured — 14 View_Fact_* views):
              ├─► getNumericColumns()  — discover which columns are numeric
              ├─► buildUnpivotBranch() — build SQL to UNPIVOT wide → long
              ├─► queryBiomarkerLong() — execute query, return BiomarkerRow[]
              └─► On failure → fallback to demo data
        │
        ▼
  Server computes:
    correlationMatrix(rows)  → Pearson r for all biomarker pairs
    summaryStats(rows)       → mean, std, min, max, n per biomarker
    biomarkerGroups          → group biomarkers by source table
        │
        ▼
  JSON response → Browser
    Dashboard renders:
      • Longitudinal trend chart   (line chart, drill: year→month→day)
      • Monthly mean chart         (line chart, always monthly)
      • Scatter plot               (user picks X and Y biomarkers)
      • Correlation heatmap        (Pearson matrix)
      • OLAP 3D cube               (bar3D, slice/dice/drill)

USER asks a question → POST /api/explain
    │
    ├─► buildEnrichedPrompt()
    │     ├── Attach date-level biomarker values (up to 250 rows)
    │     ├── Flag values outside clinical reference ranges (HIGH/LOW)
    │     ├── Attach notable correlations (|r| > 0.3)
    │     └── detectClinicalPatterns() — multi-biomarker alerts
    │
    ├─► Try Google Gemini         → return if success
    ├─► Try HuggingFace MedGemma  → return if success
    ├─► Try OpenAI GPT-5.5        → return if success
    └─► Fallback: localStubAnswer → structured data snapshot (no LLM)
```

---

## 3. Types & Data Shapes

```
// src/types/index.ts

TYPE BiomarkerRow:
    patient_id  : string     // e.g. "P0001"
    visit_date  : string     // ISO date "2019-03-15"
    biomarker   : string     // e.g. "Hemoglobin", "ALT_SGPT"
    value       : number     // numeric measurement
    group?      : string     // source table name (optional)

TYPE DataResponse:
    source          : "bigquery" | "demo"
    demoReason?     : string           // why demo mode was used
    rows            : BiomarkerRow[]
    biomarkers      : string[]         // sorted unique biomarker names
    biomarkerGroups?: { [group]: string[] }  // table → biomarkers
    dateRange       : { min, max }
    rowCount        : number
    correlation?    : { [bioA]: { [bioB]: number } }  // Pearson matrix
    summary?        : { [bio]: { mean, std, min, max, n } }
```

---

## 4. Environment & Configuration

```
// src/lib/env.ts

FUNCTION getServerEnv():
    Parse environment variables with Zod schema:
        GCP_PROJECT_ID        → Google Cloud project
        BIGQUERY_LOCATION     → default "US"
        BIGQUERY_DATASET      → default "A2"
        BIGQUERY_VIEW_NAMES   → comma-separated table/view names
                                 (e.g. "View_Fact_CBC,View_Fact_Liver_Function,...")
        BIGQUERY_TABLE_FQN    → fully qualified table name
        BQ_COL_PATIENT_ID     → column name for patient ID (default "patient_id")
        BQ_COL_VISIT_DATE     → column name for visit date (default "visit_date")
        BQ_COL_BIOMARKER      → column name for biomarker
        BQ_COL_VALUE          → column name for value
        VERTEX_LOCATION       → GCP region for Vertex AI
        VERTEX_MODEL          → Vertex model name
        HUGGINGFACE_MODEL     → default "google/medgemma-27b-text-it"
    RETURN validated config object

    NOTE: For the included Dataset, set:
        BQ_COL_PATIENT_ID = Original_MedID
        BQ_COL_VISIT_DATE = Test_Date
        BIGQUERY_VIEW_NAMES = all 14 View_Fact_* names

FUNCTION isDemoMode():
    RETURN true IF process.env.DEMO_MODE === "true"

FUNCTION parseBigQueryViewNames(env):
    Split BIGQUERY_VIEW_NAMES by comma
    Filter out empty strings
    Validate each name matches /^[A-Za-z_][A-Za-z0-9_]*$/
    RETURN list of safe view names
```

---

## 5. API Routes

### 5.1 POST /api/data

```
// src/app/api/data/route.ts

INPUT: { dateFrom, dateTo, biomarkers?, rowLimit?, patientId? }
VALIDATE with Zod (dates must be YYYY-MM-DD, rowLimit 100–200000)

DECIDE data source:
    IF DEMO_MODE=true           → use demo data, set reason
    ELSE IF no GCP_PROJECT_ID   → use demo data, set reason
    ELSE IF no tables configured → use demo data, set reason
    ELSE IF placeholder table   → use demo data, set reason
    ELSE:
        TRY queryBiomarkerLong(env, params)
            → source = "bigquery"
        CATCH error:
            → fallback to demo, log error, set reason

POST-PROCESS:
    Extract unique biomarker list (sorted)
    Compute correlationMatrix(rows, biomarkerList)
    Compute summaryStats(rows, biomarkerList)
    Build biomarkerGroups from row.group field

RETURN DataResponse JSON
```

### 5.2 POST /api/explain

```
// src/app/api/explain/route.ts

INPUT: { question, context: { filters, dataSource, summary, correlation, rows, rowCount, chartHint } }
VALIDATE with Zod

BUILD enriched prompt:
    1. Include date-level values (up to 250 rows, sorted by date)
    2. Flag each value as HIGH/LOW against CLINICAL_RANGES
    3. OR include annotated aggregate stats if no raw rows
    4. Extract notable correlations (|r| > 0.3)
    5. Run detectClinicalPatterns() for multi-biomarker alerts
    6. Append clinical reference ranges for context
    7. Add analysis instructions for the LLM

TRY providers in order:
    1. HuggingFace MedGemma  (if HUGGINGFACE_API_KEY set)
         → POST to OpenAI-compatible chat endpoint
         → Strip internal thinking tokens (<unusedNN>)
         → Return { answer, mode: "medgemma" }

    2. OpenAI GPT-5.5  (if OPENAI_API_KEY set)
         → Use responses.create() API
         → Return { answer, mode: "openai" }

    3. Local stub fallback (no LLM available)
         → Format a structured data snapshot as plain text
         → Return { answer, mode: "local_stub", warning }

NOTE: gemini.ts is available as an additional provider (Google Gemini
      API with retry/backoff, model fallback gemini-2.5-flash →
      gemini-2.0-flash). Configure via GEMINI_API_KEY env var.
```

### 5.3 GET /api/patients

```
// src/app/api/patients/route.ts

DECIDE source (same logic as /api/data):
    IF BigQuery available:
        TRY queryDistinctPatients(env)
            → SELECT DISTINCT patient_id FROM first table
            → RETURN { patientIds, totalReports }
        CATCH → fall through

FALLBACK:
    Generate 48 demo IDs: P0001..P0048
    RETURN { patientIds, totalReports: 48 }
```

### 5.4 GET /api/health

```
// src/app/api/health/route.ts

RETURN { ok: true, service: "healthcare-dashboard" }
// Simple health check endpoint for monitoring
```

---

## 6. Library Modules

### 6.1 BigQuery Client

```
// src/lib/bigquery.ts

FUNCTION getNumericColumns(client, project, dataset, viewNames, ignoreCols):
    Query INFORMATION_SCHEMA.COLUMNS for INT64/FLOAT64/NUMERIC columns
    Exclude non-biomarker columns (patient_id, visit_date, names, etc.)
    RETURN { tableName: [col1, col2, ...] }

FUNCTION buildUnpivotBranch(fullTableId, tableName, cols, pid, vd, ...):
    Build SQL that:
        1. SELECT patient_id, visit_date, and CAST all numeric cols to FLOAT64
        2. UNPIVOT(value FOR biomarker IN (col1, col2, ...))
        3. Apply WHERE filters: date range, optional biomarker list, optional patient
        4. Tag each row with group = tableName
    RETURN SQL string fragment

FUNCTION queryBiomarkerLong(env, params):
    CREATE BigQuery client
    DETERMINE source: multiple views (UNION ALL) or single table
    GET numeric columns for each view/table
    BUILD unpivot SQL branch for each table
    COMBINE with UNION ALL, ORDER BY visit_date, LIMIT rowLimit
    EXECUTE query (max 5GB billed)
    MAP results to BiomarkerRow[]
    RETURN rows

    NOTE: When using the included Dataset, this function queries
    all 14 View_Fact_* analytics views, each contributing biomarkers
    from a different clinical domain (CBC, Liver, Kidney, etc.).

FUNCTION queryDistinctPatients(env):
    SELECT DISTINCT patient_id FROM first available table
    RETURN sorted list of patient ID strings
```

### 6.2 Statistics

```
// src/lib/stats.ts

FUNCTION pearson(xs, ys):
    IF fewer than 2 paired values → RETURN null
    Compute Pearson correlation coefficient:
        r = (n·Σxy − Σx·Σy) / √((n·Σx² − (Σx)²)(n·Σy² − (Σy)²))
    RETURN r

FUNCTION groupedByPatientDate(rows):
    Group rows by "patient_id|visit_date" composite key
    RETURN Map<key, { biomarker: value, ... }>

FUNCTION correlationMatrix(rows, biomarkers):
    Group rows by patient+date
    FOR each pair (a, b) of biomarkers:
        Collect paired values from same visit
        Compute pearson(a_values, b_values)
        Diagonal = 1.0
    RETURN nested Record { bioA: { bioB: r } }

FUNCTION summaryStats(rows, biomarkers):
    FOR each biomarker:
        Collect all values
        Compute mean, std (sample), min, max, n
    RETURN Record { bio: { mean, std, min, max, n } }
```

### 6.3 Clinical Ranges

```
// src/lib/clinical-ranges.ts

CONSTANT CLINICAL_RANGES:
    Dictionary of ~40 biomarkers with:
        low, high     — normal reference range boundaries
        unit          — measurement unit (g/dL, U/L, etc.)
        highMeaning   — what elevated values suggest
        lowMeaning    — what low values suggest

    Categories: CBC, Liver Function, Kidney Function,
                Lipid Profile, Glucose, Iron Profile, Thyroid

FUNCTION annotateWithRanges(summary):
    FOR each biomarker in summary:
        Format: "name: mean=X, std=Y, range=[min,max], n=N"
        IF clinical range exists:
            Append reference range
            Flag as ⚠ ELEVATED / ⚠ LOW / ✓ Normal
    RETURN formatted string

FUNCTION detectClinicalPatterns(summary):
    Check multi-biomarker clinical patterns:
        • ALT + AST both elevated → hepatocellular injury
        • ALP + GGT both elevated → cholestatic pattern
        • Creatinine high + eGFR < 60 → renal impairment
        • LDL high + HDL low → cardiovascular risk
        • Triglycerides > 200 → pancreatitis risk
        • Hemoglobin low + MCV → anemia subtype classification
        • TSH abnormal ± T3/T4 → thyroid dysfunction
        • Fasting glucose ≥ 126 → diabetes threshold
    RETURN list of alert strings
```

### 6.4 Demo Data Generator

```
// src/lib/demo-data.ts

CONSTANT BIOMARKERS = [glucose, hba1c, creatinine, alt, hemoglobin, wbc]

FUNCTION generateDemoRows({ dateFrom, dateTo, biomarkerFilter?, patientId? }):
    Generate 48 synthetic patients (P0001–P0048), or single if patientId given
    FOR each patient:
        Seed = deterministic hash of patient ID
        FOR each month in [dateFrom..dateTo]:
            FOR each biomarker:
                Base value depends on biomarker type
                Add sinusoidal noise for realistic variation
                Glucose gets a slow drift over time
                PUSH row to results
    SORT by (visit_date, patient_id)
    RETURN rows
```

### 6.5 AI Providers

```
// src/lib/gemini.ts

FUNCTION generateExplanationGemini(apiKey, prompt):
    POST to Gemini REST API (no SDK dependency)
    Try primary model (gemini-2.5-flash), fallback to gemini-2.0-flash
    Retry with exponential backoff on 429/5xx (max 2 retries)
    Timeout: 30 seconds per attempt
    Handle safety filter blocks
    System instruction: clinical research assistant role with strict rules
    RETURN response text

// src/lib/huggingface.ts

FUNCTION generateExplanationHuggingFace(apiKey, prompt):
    POST to OpenAI-compatible chat endpoint (Featherless AI or HuggingFace)
    Model: google/medgemma-27b-text-it (configurable)
    Timeout: 120 seconds
    Strip MedGemma thinking tokens: <unusedNN>thought...</unusedNN>
    Handle specific HTTP errors with actionable messages
    RETURN cleaned response text

// src/lib/openai.ts

FUNCTION generateExplanationOpenAI(apiKey, prompt):
    Create OpenAI client (supports custom base URL)
    Call responses.create with model "gpt-5.5"
    System instruction: clinical research assistant role with strict rules
    RETURN trimmed response text

// src/lib/vertex.ts

FUNCTION generateExplanation(env, prompt):
    Create Vertex AI client with GCP credentials
    Call generativeModel.generateContent()
    System instruction: clinical research assistant
    RETURN response text
```

---

## 7. Frontend Components

### 7.1 Dashboard (Main Component)

```
// src/components/Dashboard.tsx

COMPONENT Dashboard:

  STATE:
    dateFrom, dateTo          — date range filter
    patientId, patientSearch  — patient selection with autocomplete
    data: DataResponse        — fetched dataset
    selectedBiomarkers[]      — which biomarkers to chart
    scatterX, scatterY        — scatter plot axis selections
    drillLevel (year|month|day), drillYear, drillMonth — drill state
    question, answer          — AI explain panel

  ON MOUNT:
    Fetch GET /api/patients → populate patient dropdown

  ON FILTER CHANGE (debounced 350ms):
    POST /api/data { dateFrom, dateTo, patientId, rowLimit: 80000 }
    Auto-select first biomarker group if available

  HELPER timeTrend(rows, biomarkers, level, drillYear?, drillMonth?):
    Filter rows to drill scope
    Group by time key (year/month/day)
    Compute mean per (time, biomarker)
    RETURN { labels, series } for ECharts line chart

  HELPER scatterPairs(rows, xKey, yKey):
    Group by patient+date
    Collect (x, y) pairs where both biomarkers present
    RETURN coordinate array

  HELPER computeCorrelation(rows, biomarkers):
    Client-side Pearson correlation (same algorithm as server)
    Used so heatmap updates when user drills into time scope

  RENDER:
    ┌──────────────────────────────────────────┐
    │ HEADER: Title, source badge, row count   │
    ├──────────┬───────────────────────────────┤
    │ SIDEBAR  │  CHART GRID                   │
    │ Filters: │  ┌─────────┬─────────┐        │
    │ • Patient│  │ Trend   │ Monthly │        │
    │ • Dates  │  │ (drill) │ Mean    │        │
    │ • Biomar.│  ├─────────┼─────────┤        │
    │   groups │  │ Scatter │ Heatmap │        │
    │          │  └─────────┴─────────┘        │
    ├──────────┴───────────────────────────────┤
    │ OLAP CUBE (3D bar chart)                 │
    ├──────────────────────────────────────────┤
    │ AI EXPLAIN PANEL                         │
    │ [Question input] [Ask button]            │
    │ [Answer rendered as markdown → HTML]     │
    └──────────────────────────────────────────┘

  DRILL INTERACTION:
    Click on trend chart label:
      year → drills to months of that year
      month → drills to days of that month
    Breadcrumb navigation: All Years > 2019 > 2019-03
    Drill state propagates to scatter + heatmap

  AI EXPLAIN:
    User types question → POST /api/explain with:
      question, filters, rows, correlation, rowCount, chartHint
    Answer rendered via lightweight markdown→HTML converter
    Supports: headers, bold, italic, code blocks, tables, lists
```

### 7.2 OLAP Cube

```
// src/components/OlapCube.tsx

COMPONENT OlapCube(data, loading, selectedBiomarkers, onFilter):

  DIMENSIONS: time | biomarker | patient | group
  OPERATIONS: slice (fix one member) | dice (select multiple members)

  STATE:
    grain: "day" | "month"
    dims: { x, y, slice } — which dimension on each axis
    op: "slice" | "dice"
    sliceValue, diceSelected[], timeFrom, timeTo
    activeFilters — tracks clicked bar filters

  FUNCTION buildCube(rows, { grain, biomarkers }):
    Aggregate: avg(value) grouped by (time, biomarker, patient, group)
    RETURN { times[], biomarkers[], patients[], groups[], aggregation_map }

  FUNCTION filteredData:
    Based on op:
      SLICE → include only rows matching sliceValue on slice dimension
      DICE  → include rows matching selected members or time range
    Aggregate across z-dimension for each (x, y) cell
    RETURN { xCats, yCats, seriesData: [xi, yi, avg_value][] }

  RENDER:
    Controls panel (left):
      • Biomarker cap slider (performance)
      • Slice / Dice toggle
      • X / Y / Slice dimension selectors
      • Slice member dropdown OR dice member checkboxes
    3D Chart (right):
      • ECharts bar3D with realistic shading
      • Auto-rotate, interactive orbit
      • Click bar → set activeFilters → propagate to Dashboard

  CROSS-FILTERING:
    Click a bar → extracts (x, y) values
    Maps to patient/biomarker/time filters
    Calls onFilter(payload) → Dashboard re-fetches data
```

### 7.3 Page Transition

```
// src/components/PageTransition.tsx

COMPONENT PageTransition(children):
    Wraps page content with Framer Motion AnimatePresence
    On route change: 3D rotation + fade animation
    Respects prefers-reduced-motion
```

---

## 8. AI Explanation Pipeline

```
SEQUENCE: User asks "Why is ALT elevated?"

1. Dashboard.askLlm() sends POST /api/explain:
     { question: "Why is ALT elevated?",
       context: { rows (all data), filters, correlation, ... } }

2. Server validates input with Zod

3. buildEnrichedPrompt() assembles rich context:
     "── Date-level Biomarker Values ──"
     "2019-01-15 | ALT_SGPT: 78.000 (HIGH)"
     "2019-01-15 | AST_SGOT: 42.000 (HIGH)"
     ...
     "── Notable Correlations (Pearson) ──"
     "ALT_SGPT × AST_SGOT: r=0.847"
     ...
     "── Detected Clinical Patterns ──"
     "⚠ Both ALT and AST elevated — hepatocellular injury"
     ...
     "── Clinical Reference Ranges ──"
     "ALT_SGPT: 7-56 U/L"

4. Provider cascade:
     Google Gemini (2.5-flash, retry + fallback to 2.0-flash)
       → HuggingFace MedGemma (27B clinical model)
       → OpenAI GPT-5.5
       → local stub

5. Response streamed back → rendered as formatted markdown
```

---

## 9. OLAP Cube Engine

```
The OLAP cube implements four classic operations:

SLICE:  Fix one dimension to a single value
        Example: slice on patient = "P0012"
        → Show biomarker × time for just that patient

DICE:   Select a sub-cube by choosing multiple members
        Example: dice on time = [2019-01, 2019-02, 2019-03]
        → Show only those months

DRILL:  Change granularity
        Example: drill down from month → day
        → More detailed time axis

ACROSS: Swap axes
        Example: swap X(time) ↔ Y(biomarker)
        → Rotated perspective of the same data

Cross-filtering:
    Click a 3D bar → extract (x_value, y_value)
    Map to dashboard filters (patientId, biomarkers, dateRange)
    Dashboard re-fetches with new filters
    All charts update to reflect the drill-through
```

---

## 10. Included Dataset & BigQuery Star Schema

The `Dataset/` directory contains the complete medical-records dataset that powers the dashboard when connected to BigQuery.

### Source Data

```
Dataset/
├── AgeCategories.csv        # 7 rows — age-range → life-stage labels
├── MedIDDetails.csv         # 1,155 rows — patient demographics
├── Medical Records.csv      # 13,849 rows × 96 columns — lab results
├── Script 2.0.pdf           # Consolidated SQL reference (58 pages)
└── Script/
    ├── Dimension/           # 6 SQL scripts (surrogate-key lookup tables)
    │   ├── MedID_Dimension.sql
    │   ├── LabReference_Dimension.sql
    │   ├── SampleID_Dimension.sql
    │   ├── Collected_Dimension.sql
    │   ├── Time_Dimension.sql
    │   └── Reported_Time_Dimension.sql
    ├── Fact/                # 14 SQL scripts (domain-specific measure tables)
    │   ├── Fact_Urine.sql           Fact_HbA1c.sql
    │   ├── Fact_CBC.sql             Fact_Urine_ACR.sql
    │   ├── Fact_Platelet_Profile.sql Fact_Calcium_Phos.sql
    │   ├── Fact_Lipid_Profile.sql   Fact_Thyroid_Profile.sql
    │   ├── Fact_Liver Function.sql  Fact_Glucose_Fasting.sql
    │   ├── Fact_Kidney_Function.sql Fact_Glucose_PP.sql
    │   └── Fact_Iron_Profile.sql    Fact_Glucose_Diagnopath.sql
    └── View Fact/           # 14 SQL scripts (denormalized analytics views)
        ├── View_Fact_Urine.sql      View_Fact_HbA1c.sql
        ├── View_Fact_CBC.sql        View_Fact_Urine_ACR.sql
        └── ... (one per fact table)
```

### Schema Pipeline

```
3 CSVs → 6 Dimensions → 14 Fact Tables → 14 Analytics Views
                                            ↓
                              Dashboard queries via UNION ALL
                              (BIGQUERY_VIEW_NAMES = all 14 views)
```

### Loading Into BigQuery

1. Upload the 3 CSVs to BigQuery dataset `bigquery-tutorial-480009.A2`.
2. Run SQL scripts in order: `Dataset/Script/Dimension/*.sql` → `Dataset/Script/Fact/*.sql` → `Dataset/Script/View Fact/*.sql`.
3. Set `BIGQUERY_VIEW_NAMES` in `.env.local` to the 14 `View_Fact_*` view names.
4. Set `BQ_COL_PATIENT_ID=Original_MedID` and `BQ_COL_VISIT_DATE=Test_Date` (column names in the views).

For detailed schema documentation, see `Dataset/README.md`, `Dataset/walkthrough.md`, and `Dataset/pseudocode.md`.

---

*This document was auto-generated to explain the system architecture and code logic of the Healthcare Dashboard.*
