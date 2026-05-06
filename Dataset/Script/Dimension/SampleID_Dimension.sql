CREATE OR REPLACE TABLE `bigquery-tutorial-480009.A2.SampleID_Dimension`
(
  ID INT64 NOT NULL,
  Sample_ID STRING NOT NULL
)
AS
SELECT
  -- Generates a sequential ID (1, 2, 3...)
  ROW_NUMBER() OVER (ORDER BY `Sample ID`) AS ID,
  
  -- Cast the original integer ID to String
  CAST(`Sample ID` AS STRING) AS Sample_ID
FROM (
  -- Select distinct samples to ensure uniqueness
  SELECT DISTINCT `Sample ID`
  FROM `bigquery-tutorial-480009.A2.Medical_Records_Cleaned`
  WHERE `Sample ID` IS NOT NULL
);