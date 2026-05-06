# Biomarker Observatory — Healthcare Dashboard

A high-performance, AI-augmented healthcare analytics dashboard built with Next.js, BigQuery, and Vertex AI. Explore longitudinal trends, correlation structures, and clinical insights across patient cohorts with ease.

## 🚀 Features

-   **BigQuery Integration**: Directly query large-scale healthcare data stored in Google BigQuery via **14 analytics-ready views** (star-schema, UNION ALL long-format).
-   **Included Dataset**: Ships with the full medical-records dataset (`Dataset/`) — 3 source CSVs, individual SQL scripts for dimensions/facts/views, and the original `Script 2.0.pdf` — ready for one-click BigQuery loading.
-   **AI Clinical Assistant**: Cascading provider chain — **Google Gemini** (primary, API-key auth), **Hugging Face MedGemma** (clinical specialist), **OpenAI GPT-5.5** (fallback), or local stub — providing natural language explanations and insights for complex biomarker data.
-   **Dynamic Visualizations**: 
    -   **Longitudinal Trends**: Multi-level drill-down (Year → Month → Day) to observe biomarker changes over time.
    -   **Interactive Scatter Plots**: Analyze relationships between biomarker pairs within the same visit.
    -   **Correlation Heatmaps**: Visualize the Pearson correlation structure across the entire cohort or specific filters.
    -   **3D OLAP Cube**: Advanced multidimensional data exploration (via `OlapCube.tsx`).
-   **Intelligent Filtering**: Granular filtering by date range, patient ID (with searchable autocomplete), and biomarker groups.
-   **Responsive & High-Performance**: Built with Next.js 15, React 19, and ECharts for smooth interaction with large datasets.

## 🛠️ Tech Stack

-   **Framework**: [Next.js 15](https://nextjs.org/) (App Router, TypeScript)
-   **Styling**: [Tailwind CSS](https://tailwindcss.com/) & Vanilla CSS
-   **Visualizations**: [Apache ECharts](https://echarts.apache.org/) & [Framer Motion](https://framer.com/motion/)
-   **Cloud Infrastructure**: [Google Cloud Platform (GCP)](https://cloud.google.com/)
    -   **Database**: [BigQuery](https://cloud.google.com/bigquery)
    -   **AI**: [Vertex AI (Gemini)](https://cloud.google.com/vertex-ai)
-   **AI Providers**: [Google Gemini API](https://ai.google.dev/) (primary), [HuggingFace MedGemma](https://huggingface.co/google/medgemma-27b-text-it) (clinical), [OpenAI API](https://openai.com/api/) (fallback)

## 🏁 Getting Started

### Prerequisites

-   Node.js 18.x or later
-   NPM or Yarn
-   A Google Cloud Project (for BigQuery/Vertex AI features)

### Installation

1.  **Clone the repository**:
    ```bash
    git clone <repository-url>
    cd healthcare-dashboard
    ```

2.  **Install dependencies**:
    ```bash
    npm install
    ```

3.  **Environment Setup**:
    Copy the example environment file:
    ```bash
    cp .env.example .env.local
    ```
    Fill in your GCP credentials and API keys in `.env.local`. If no credentials are provided, the app will default to **Demo Mode** with synthetic data.

4.  **Load the Dataset into BigQuery** *(optional — only needed for live data)*:
    - Upload the 3 CSVs from `Dataset/` to your BigQuery dataset (`A2`).
    - Run the SQL scripts in `Dataset/Script/` in order: **Dimension → Fact → View Fact**.
    - Or follow the consolidated instructions in `Dataset/Script 2.0.pdf`.

5.  **Run locally**:
    ```bash
    npm run dev
    ```
    Open [http://localhost:3000](http://localhost:3000) in your browser.

## ⚙️ Environment Variables

| Variable | Description |
| :--- | :--- |
| `DEMO_MODE` | Set to `true` to force synthetic data even if GCP is configured. |
| `GOOGLE_APPLICATION_CREDENTIALS` | Path to your GCP Service Account JSON key. |
| `GCP_PROJECT_ID` | Your Google Cloud Project ID. |
| `BIGQUERY_DATASET` | The BigQuery dataset to query (default: `A2`). |
| `BIGQUERY_VIEW_NAMES` | Comma-separated list of BigQuery view names to UNION ALL (e.g. all 14 `View_Fact_*` views). |
| `BIGQUERY_TABLE_FQN` | Fully qualified name of a single BigQuery table (alternative to `BIGQUERY_VIEW_NAMES`). |
| `BQ_COL_PATIENT_ID` | Column name for patient ID in your views (default: `Original_MedID`). |
| `BQ_COL_VISIT_DATE` | Column name for visit date in your views (default: `Test_Date`). |
| `VERTEX_LOCATION` | GCP region for Vertex AI (e.g., `us-central1`). |
| `VERTEX_MODEL` | Vertex AI model name (e.g., `gemini-1.5-flash`). |
| `GEMINI_API_KEY` | Google Gemini API key for the primary LLM explain provider. |
| `GEMINI_MODEL` | Gemini model name (default: `gemini-2.5-flash`). |
| `HUGGINGFACE_API_KEY` | Hugging Face token used for MedGemma inference. |
| `HUGGINGFACE_MODEL` | Hugging Face model id (default: `google/medgemma-27b-text-it`). |
| `OPENAI_API_KEY` | OpenAI API key for fallback interpretation services. |

## 📁 Project Structure

```text
src/
├── app/            # Next.js App Router (pages and API routes)
│   └── api/        # Backend endpoints (data, explain, patients, health)
├── components/     # React components (Dashboard, OlapCube, etc.)
├── lib/            # Shared utilities (BigQuery client, AI logic, stats)
│   ├── bigquery.ts       # BigQuery UNPIVOT queries, dynamic column discovery
│   ├── gemini.ts         # Google Gemini API provider (primary LLM)
│   ├── huggingface.ts    # HuggingFace MedGemma provider (clinical)
│   ├── openai.ts         # OpenAI GPT-5.5 provider (fallback)
│   ├── clinical-ranges.ts # ~40 biomarker reference ranges + pattern detection
│   ├── stats.ts          # Pearson correlation, summary statistics
│   ├── demo-data.ts      # Synthetic data generator for demo mode
│   └── env.ts            # Zod-validated environment configuration
├── types/          # TypeScript definitions
Dataset/
├── AgeCategories.csv       # Age-range → life-stage mapping (7 rows)
├── MedIDDetails.csv        # Patient demographics (1,155 rows)
├── Medical Records.csv     # Lab results (13,849 rows, 96 columns)
├── Script 2.0.pdf          # Original consolidated SQL reference (58 pages)
├── Script/
│   ├── Dimension/          # 6 dimension table SQL scripts
│   ├── Fact/               # 14 fact table SQL scripts
│   └── View Fact/          # 14 analytics view SQL scripts
├── README.md               # Dataset architecture & schema docs
├── walkthrough.md          # Step-by-step SQL execution guide
└── pseudocode.md           # Pseudocode for every SQL object
public/             # Static assets
scripts/            # Utility scripts for data processing or deployment
PSEUDOCODE.md       # Detailed pseudocode & system walkthrough
```

## 📖 Documentation

For a detailed explanation of how every module works, the data flow from BigQuery to the browser, and the AI explanation pipeline, see **[PSEUDOCODE.md](./PSEUDOCODE.md)**.

It covers:
-   System architecture overview with ASCII diagrams
-   Data types and shapes
-   API route logic (data fetching, AI explain, patient listing)
-   BigQuery UNPIVOT strategy for wide-to-long transformation
-   Statistics engine (Pearson correlation, summary stats)
-   Clinical reference ranges and pattern detection
-   OLAP cube operations (slice, dice, drill, across)
-   AI provider cascade (Gemini → MedGemma → OpenAI → local stub)

For the included medical-records dataset and its BigQuery star-schema design, see **[Dataset/README.md](./Dataset/README.md)**.

## 📄 License