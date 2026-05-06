CREATE OR REPLACE TABLE `bigquery-tutorial-480009.A2.Fact_Platelet_Profile`
(
  -- Foreign Keys
  MedID_FK INT64 NOT NULL,
  LabReference_FK INT64 NOT NULL,
  SampleID_FK INT64 NOT NULL,
  Collected_FK INT64 NOT NULL,
  Time_FK INT64 NOT NULL,
  Reported_Time_FK INT64 NOT NULL,

  -- Platelet Facts (Measures)
  Platelet_Count INT64 NOT NULL,
  MPV FLOAT64 NOT NULL,
  Platelet_RDW INT64 NOT NULL,
  PCT FLOAT64 NOT NULL,
  P_LCR FLOAT64 NOT NULL,
  IMG FLOAT64 NOT NULL,
  IMM FLOAT64 NOT NULL,
  IML FLOAT64 NOT NULL,
  LIC FLOAT64 NOT NULL
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

  -- PLATELET FACTS (Measures)
  COALESCE(f.`Platelet Count __10_3_µL_`, 0) AS Platelet_Count,
  COALESCE(f.`MPV _fL_`, 0.0) AS MPV,
  COALESCE(f.`Platelet RDW %`, 0) AS Platelet_RDW,
  COALESCE(f.`PCT %`, 0.0) AS PCT,
  COALESCE(f.`P-LCR %`, 0.0) AS P_LCR,
  COALESCE(f.`IMG %`, 0.0) AS IMG,
  COALESCE(f.`IMM %`, 0.0) AS IMM,
  COALESCE(f.`IML %`, 0.0) AS IML,
  COALESCE(f.`LIC %`, 0.0) AS LIC

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