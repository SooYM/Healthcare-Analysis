-- Run in BigQuery (SQL workspace) for project bigquery-tutorial-480009 / dataset A2.
-- Pick one TABLE or VIEW whose rows match the app shape: patient_id, visit_date, biomarker, value.

SELECT table_name, table_type
FROM `bigquery-tutorial-480009.A2.INFORMATION_SCHEMA.TABLES`
ORDER BY table_type, table_name;
