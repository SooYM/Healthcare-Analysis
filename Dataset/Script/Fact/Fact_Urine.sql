CREATE OR REPLACE TABLE `bigquery-tutorial-480009.A2.Fact_Urine`
(
  -- Foreign Keys (Linking to Dimensions)
  MedID_FK INT64 NOT NULL,
  LabReference_FK INT64 NOT NULL,
  SampleID_FK INT64 NOT NULL,
  Collected_FK INT64 NOT NULL,
  Time_FK INT64 NOT NULL,
  Reported_Time_FK INT64 NOT NULL,

  -- Urine Facts
  Urine_Colour STRING NOT NULL,
  Appearance STRING NOT NULL,
  Specific_Gravity FLOAT64 NOT NULL,
  pH FLOAT64 NOT NULL,
  Proteins STRING NOT NULL,
  Glucose STRING NOT NULL,
  Bilirubin STRING NOT NULL,
  Ketones STRING NOT NULL,
  Blood STRING NOT NULL,
  Urobilinogen STRING NOT NULL,
  Nitrites STRING NOT NULL,
  WBC_Pus_Cells STRING NOT NULL,
  RBC STRING NOT NULL,
  Epithelial_Cells STRING NOT NULL,
  Casts STRING NOT NULL,
  Crystals STRING NOT NULL,
  Others STRING NOT NULL
)
AS
SELECT
  -- FOREIGN KEYS (Use COALESCE to handle any missing links, default to -1)
  COALESCE(d_med.ID, -1) AS MedID_FK,
  COALESCE(d_lab.ID, -1) AS LabReference_FK,
  COALESCE(d_samp.ID, -1) AS SampleID_FK,
  COALESCE(d_coll.ID, -1) AS Collected_FK,
  COALESCE(d_time.ID, -1) AS Time_FK,
  COALESCE(d_rep.ID, -1) AS Reported_Time_FK,

  -- URINE FACTS (Handle Nulls with Defaults)
  COALESCE(f.`Urine Colour`, 'Unknown') AS Urine_Colour,
  COALESCE(f.Appearance, 'Unknown') AS Appearance,
  COALESCE(f.`Specific Gravity`, 0.0) AS Specific_Gravity,
  COALESCE(f.pH, 0.0) AS pH,
  COALESCE(f.Proteins, 'Unknown') AS Proteins,
  COALESCE(f.Glucose, 'Unknown') AS Glucose,
  COALESCE(f.Bilirubin, 'Unknown') AS Bilirubin,
  COALESCE(f.Ketones, 'Unknown') AS Ketones,
  COALESCE(f.Blood, 'Unknown') AS Blood,
  COALESCE(f.Urobilinogen, 'Unknown') AS Urobilinogen,
  COALESCE(f.Nitrites, 'Unknown') AS Nitrites,
  
  -- Map the exact column names from your schema to clean names
  COALESCE(f.`WBC _Pus Cells_ __HPF_`, 'Unknown') AS WBC_Pus_Cells,
  COALESCE(f.RBC, 'Unknown') AS RBC,
  COALESCE(f.`Epithelial Cells __HPF_`, 'Unknown') AS Epithelial_Cells,
  
  COALESCE(f.Casts, 'Unknown') AS Casts,
  COALESCE(f.Crystals, 'Unknown') AS Crystals,
  COALESCE(f.Others, 'Unknown') AS Others

FROM
  `bigquery-tutorial-480009.A2.Medical_Records_Cleaned` f

-- JOINING DIMENSIONS
-- Note: Casting Fact IDs to STRING to match Dimension definitions
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