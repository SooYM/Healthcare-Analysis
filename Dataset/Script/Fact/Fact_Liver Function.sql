CREATE OR REPLACE TABLE `bigquery-tutorial-480009.A2.Fact_Liver_Function`
(
  -- Foreign Keys
  MedID_FK INT64 NOT NULL,
  LabReference_FK INT64 NOT NULL,
  SampleID_FK INT64 NOT NULL,
  Collected_FK INT64 NOT NULL,
  Time_FK INT64 NOT NULL,
  Reported_Time_FK INT64 NOT NULL,

  -- Liver Function Facts (Measures)
  Bilirubin_Total FLOAT64 NOT NULL,
  Bilirubin_Direct FLOAT64 NOT NULL,
  Bilirubin_Indirect FLOAT64 NOT NULL,
  ALP INT64 NOT NULL,
  ALT_SGPT INT64 NOT NULL,
  AST_SGOT INT64 NOT NULL,
  GGT INT64 NOT NULL,
  Protein_Total FLOAT64 NOT NULL,
  Albumin FLOAT64 NOT NULL,
  Globulin FLOAT64 NOT NULL,
  A_G_Ratio FLOAT64 NOT NULL
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

  -- LIVER FUNCTION FACTS (Measures)
  COALESCE(f.`Bilirubin Total _mg_dL_`, 0.0) AS Bilirubin_Total,
  COALESCE(f.`Bilirubin Direct _mg_dL_`, 0.0) AS Bilirubin_Direct,
  COALESCE(f.`Bilirubin Indirect _mg_dL_`, 0.0) AS Bilirubin_Indirect,
  COALESCE(f.`ALP _U_L_`, 0) AS ALP,
  COALESCE(f.`ALT_SGPT _U_L_`, 0) AS ALT_SGPT,
  COALESCE(f.`AST_SGOT _U_L_`, 0) AS AST_SGOT,
  COALESCE(f.`GGT _U_L_`, 0) AS GGT,
  COALESCE(f.`Protein Total _g_dL_`, 0.0) AS Protein_Total,
  COALESCE(f.`Albumin _g_dL_`, 0.0) AS Albumin,
  COALESCE(f.`Globulin _g_dL_`, 0.0) AS Globulin,
  
  -- Converting A/G Ratio string to Float for proper analysis
  COALESCE(SAFE_CAST(f.`A_G Ratio` AS FLOAT64), 0.0) AS A_G_Ratio

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