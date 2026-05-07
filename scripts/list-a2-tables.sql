-- Run in BigQuery (SQL workspace) for project healthcare-dashboard-495507 / dataset A2.
-- Pick one TABLE or VIEW whose rows match the app shape: patient_id, visit_date, biomarker, value.

SELECT table_name, table_type
FROM `healthcare-dashboard-495507.A2.INFORMATION_SCHEMA.TABLES`
ORDER BY table_type, table_name;
