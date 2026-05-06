CREATE OR REPLACE TABLE `bigquery-tutorial-480009.A2.Fact_CBC`
(
  -- Foreign Keys
  MedID_FK INT64 NOT NULL,
  LabReference_FK INT64 NOT NULL,
  SampleID_FK INT64 NOT NULL,
  Collected_FK INT64 NOT NULL,
  Time_FK INT64 NOT NULL,
  Reported_Time_FK INT64 NOT NULL,

  -- CBC Facts (Measures)
  Hemoglobin FLOAT64 NOT NULL,
  RBC_Count FLOAT64 NOT NULL,
  Hematocrit FLOAT64 NOT NULL,
  MCV FLOAT64 NOT NULL,
  MCH INT64 NOT NULL,
  MCHC FLOAT64 NOT NULL,
  RDW_CV FLOAT64 NOT NULL,
  RDW_SD FLOAT64 NOT NULL,
  WBC_Count INT64 NOT NULL,
  Neutrophils INT64 NOT NULL,
  Lymphocytes INT64 NOT NULL,
  Eosinophils INT64 NOT NULL,
  Monocytes INT64 NOT NULL,
  Basophils FLOAT64 NOT NULL,      -- Note: Schema defines this as FLOAT64
  Abs_Neutrophils FLOAT64 NOT NULL,
  Abs_Lymphocytes FLOAT64 NOT NULL,
  Abs_Monocytes FLOAT64 NOT NULL,
  Abs_Eosinophils FLOAT64 NOT NULL,
  Abs_Basophils FLOAT64 NOT NULL
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

  -- CBC FACTS (Measures)
  COALESCE(f.`Hemoglobin _g_dL_`, 0.0) AS Hemoglobin,
  COALESCE(f.`RBC Count _mil_µL_`, 0.0) AS RBC_Count,
  COALESCE(f.`Hematocrit %`, 0.0) AS Hematocrit,
  COALESCE(f.`MCV _fL_`, 0.0) AS MCV,
  COALESCE(f.`MCH _pg_`, 0) AS MCH,
  COALESCE(f.`MCHC _g_dL_`, 0.0) AS MCHC,
  COALESCE(f.`RDW-CV %`, 0.0) AS RDW_CV,
  COALESCE(f.`RDW-SD _fL_`, 0.0) AS RDW_SD,
  COALESCE(f.`WBC _cells_µL_`, 0) AS WBC_Count,
  COALESCE(f.`Neutrophils %`, 0) AS Neutrophils,
  COALESCE(f.`Lymphocytes %`, 0) AS Lymphocytes,
  COALESCE(f.`Eosinophils %`, 0) AS Eosinophils,
  COALESCE(f.`Monocytes %`, 0) AS Monocytes,
  COALESCE(f.`Basophils %`, 0.0) AS Basophils,
  COALESCE(f.`Abs Neutrophils`, 0.0) AS Abs_Neutrophils,
  COALESCE(f.`Abs Lymphocytes`, 0.0) AS Abs_Lymphocytes,
  COALESCE(f.`Abs Monocytes`, 0.0) AS Abs_Monocytes,
  COALESCE(f.`Abs Eosinophils`, 0.0) AS Abs_Eosinophils,
  COALESCE(f.`Abs Basophils`, 0.0) AS Abs_Basophils

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