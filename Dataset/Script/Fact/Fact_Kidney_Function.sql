CREATE OR REPLACE TABLE `bigquery-tutorial-480009.A2.Fact_Kidney_Function`
(
  -- Foreign Keys
  MedID_FK INT64 NOT NULL,
  LabReference_FK INT64 NOT NULL,
  SampleID_FK INT64 NOT NULL,
  Collected_FK INT64 NOT NULL,
  Time_FK INT64 NOT NULL,
  Reported_Time_FK INT64 NOT NULL,

  -- Kidney Function Facts (Measures)
  Creatinine FLOAT64 NOT NULL,
  Urea FLOAT64 NOT NULL,
  BUN FLOAT64 NOT NULL,
  BUN_Creatinine_Ratio FLOAT64 NOT NULL,
  Sodium INT64 NOT NULL,
  Potassium FLOAT64 NOT NULL,
  Chloride INT64 NOT NULL,
  Uric_Acid FLOAT64 NOT NULL,
  eGFR FLOAT64 NOT NULL
)
AS
SELECT
  -- FOREIGN KEYS (Linking to Dimensions)
  COALESCE(d_med.ID, -1) AS MedID_FK,
  COALESCE(d_lab.ID, -1) AS LabReference_FK,
  COALESCE(d_samp.ID, -1) AS SampleID_FK,
  COALESCE(d_coll.ID, -1) AS Collected_FK,
  COALESCE(d_time.ID, -1) AS Time_FK,
  COALESCE(d_rep.ID, -1) AS Reported_Time_FK,

  -- KIDNEY FUNCTION FACTS (Measures)
  COALESCE(f.`Creatinine _mg_dL_`, 0.0) AS Creatinine,
  COALESCE(f.`Urea _mg_dL_`, 0.0) AS Urea,
  COALESCE(f.`BUN _mg_dL_`, 0.0) AS BUN,
  COALESCE(f.`BUN_Creatinine Ratio`, 0.0) AS BUN_Creatinine_Ratio,
  COALESCE(f.`Sodium _mmol_L_`, 0) AS Sodium,
  COALESCE(f.`Potassium _mmol_L_`, 0.0) AS Potassium,
  COALESCE(f.`Chloride _mmol_L_`, 0) AS Chloride,
  COALESCE(f.`Uric Acid _mg_dL_`, 0.0) AS Uric_Acid,
  COALESCE(f.`eGFR _mL_min_1_73m²_`, 0.0) AS eGFR

FROM
  `bigquery-tutorial-480009.A2.Medical_Records_Cleaned` f

-- JOINING DIMENSIONS
LEFT JOIN
  `bigquery-tutorial-480009.A2.MedID_Dimension` d_med
    ON CAST(f.MedID AS STRING) = d_med.Original_MedID

LEFT JOIN
  `bigquery-tutorial-480009.A2.LabReference_Dimension` d_lab
    ON f.LabReference = d_lab.LabReference

LEFT JOIN
  `bigquery-tutorial-480009.A2.SampleID_Dimension` d_samp
    ON CAST(f.`Sample ID` AS STRING) = d_samp.Sample_ID

LEFT JOIN
  `bigquery-tutorial-480009.A2.Collected_Dimension` d_coll
    ON f.Collected = d_coll.Date

LEFT JOIN
  `bigquery-tutorial-480009.A2.Time_Dimension` d_time
    ON f.Time = d_time.Time

LEFT JOIN
  `bigquery-tutorial-480009.A2.Reported_Time_Dimension` d_rep
    ON f.`Reported Time` = d_rep.Reported_Time;