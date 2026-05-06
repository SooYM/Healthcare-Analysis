# Ready Build — Deployment Guide

This folder contains the **compiled, deployment-ready** Next.js standalone build of the Healthcare Dashboard.

## Contents

| Path | Description |
|---|---|
| `server.js` | Node.js entry point |
| `.next/` | Compiled application (server + static assets) |
| `node_modules/` | Minimal production dependencies (auto-included by standalone mode) |
| `public/` | Static public assets (favicon, images, etc.) |
| `package.json` | Package metadata |

## How to Deploy

### 1. Set Environment Variables

Create a `.env.local` file (or set OS-level env vars) with:

```env
GOOGLE_APPLICATION_CREDENTIALS=path/to/bigquery-sa.json
GEMINI_API_KEY=your-gemini-api-key
GEMINI_MODEL=gemini-2.5-flash
GCP_PROJECT_ID=your-project-id
BIGQUERY_LOCATION=US
BIGQUERY_DATASET=A2
BIGQUERY_VIEW_NAMES=View_Fact_Urine,View_Fact_CBC,View_Fact_Platelet_Profile,...
DEMO_MODE=false
```

### 2. Run

```bash
node server.js
```

The application will start on **port 3000** by default.

### 3. Custom Port

```bash
PORT=8080 node server.js
```

## Notes

- This is a **standalone** build — no `npm install` required
- Node.js 18+ is required
- The BigQuery service account JSON key must be accessible at the path specified in `GOOGLE_APPLICATION_CREDENTIALS`
