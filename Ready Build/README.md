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
MYSQL_HOST=localhost
MYSQL_USER=root
MYSQL_PASSWORD=
MYSQL_DATABASE=healthcare_dashboard
MYSQL_PORT=3306
MYSQL_VIEW_NAMES=View_Fact_Urine,View_Fact_CBC,View_Fact_Platelet_Profile,View_Fact_Lipid_Profile,View_Fact_Liver_Function,View_Fact_Kidney_Function,View_Fact_Iron_Profile,View_Fact_HbA1c,View_Fact_Urine_ACR,View_Fact_Calcium_Phos,View_Fact_Thyroid_Profile,View_Fact_Glucose_Fasting,View_Fact_Glucose_PP,View_Fact_Glucose_Diagnopath
MYSQL_COL_PATIENT_ID=Original_MedID
MYSQL_COL_VISIT_DATE=Test_Date
OPENAI_API_KEY=your-openai-api-key
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
