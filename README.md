# Biomarker Observatory — Healthcare Dashboard

A high-performance, AI-augmented healthcare analytics dashboard built with Next.js, BigQuery, and Vertex AI. Explore longitudinal trends, correlation structures, and clinical insights across patient cohorts with ease.

## 🚀 Features

-   **BigQuery Integration**: Directly query large-scale healthcare data stored in Google BigQuery.
-   **AI Clinical Assistant**: Powered by Hugging Face MedGemma (primary), with OpenAI fallback, providing natural language explanations and insights for complex biomarker data.
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
-   **AI Fallback**: [OpenAI API](https://openai.com/api/)

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

4.  **Run locally**:
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
| `BIGQUERY_DATASET` | The BigQuery dataset to query. |
| `BIGQUERY_TABLE_FQN` | Fully qualified name of your BigQuery table. |
| `VERTEX_LOCATION` | GCP region for Vertex AI (e.g., `us-central1`). |
| `VERTEX_MODEL` | Vertex AI model name (e.g., `gemini-1.5-flash`). |
| `HUGGINGFACE_API_KEY` | Hugging Face token used for MedGemma inference. |
| `HUGGINGFACE_MODEL` | Hugging Face model id (default: `google/medgemma-27b-text-it`). |
| `OPENAI_API_KEY` | OpenAI API key for fallback interpretation services. |

## 📁 Project Structure

```text
src/
├── app/            # Next.js App Router (pages and API routes)
├── components/     # React components (Dashboard, OlapCube, etc.)
├── lib/            # Shared utilities (BigQuery client, AI logic, stats)
├── types/          # TypeScript definitions
public/             # Static assets
scripts/            # Utility scripts for data processing or deployment
```

## 📄 License

This project is private and intended for internal use.

---

Built with ❤️ for modern healthcare analytics.
