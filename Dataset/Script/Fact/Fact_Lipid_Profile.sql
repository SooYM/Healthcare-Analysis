CREATE OR REPLACE TABLE `bigquery-tutorial-480009.A2.Fact_Lipid_Profile`
(
  -- Foreign Keys
  MedID_FK INT64 NOT NULL,
  LabReference_FK INT64 NOT NULL,
  SampleID_FK INT64 NOT NULL,
  Collected_FK INT64 NOT NULL,
  Time_FK INT64 NOT NULL,
  Reported_Time_FK INT64 NOT NULL,

  -- Lipid Profile Facts (Measures)
  Total_Cholesterol INT64 NOT NULL,
  HDL INT64 NOT NULL,
  LDL FLOAT64 NOT NULL,
  VLDL STRING NOT NULL,          -- Kept as STRING to match source schema
  Triglycerides STRING NOT NULL, -- Kept as STRING to match source schema
  Non_HDL INT64 NOT NULL,
  Total_HDL_Ratio FLOAT64 NOT NULL,
  LDL_HDL_Ratio FLOAT64 NOT NULL,
  HDL_LDL_Ratio FLOAT64 NOT NULL
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

  -- LIPID PROFILE FACTS (Measures)
  -- Renaming to clean column names without units
  COALESCE(f.`Total Cholesterol _mg_dL_`, 0) AS Total_Cholesterol,
  COALESCE(f.`HDL _mg_dL_`, 0) AS HDL,
  COALESCE(f.`LDL _mg_dL_`, 0.0) AS LDL,
  COALESCE(f.`VLDL _mg_dL_`, 'Unknown') AS VLDL,
  COALESCE(f.`Triglycerides _mg_dL_`, 'Unknown') AS Triglycerides,
  COALESCE(f.`Non-HDL _mg_dL_`, 0) AS Non_HDL,
  COALESCE(f.`Total_HDL Ratio`, 0.0) AS Total_HDL_Ratio,
  COALESCE(f.`LDL_HDL Ratio`, 0.0) AS LDL_HDL_Ratio,
  COALESCE(f.`HDL_LDL Ratio`, 0.0) AS HDL_LDL_Ratio

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