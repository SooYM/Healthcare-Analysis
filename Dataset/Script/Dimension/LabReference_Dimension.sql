CREATE OR REPLACE TABLE `bigquery-tutorial-480009.A2.LabReference_Dimension`
(
    ID INT64 NOT NULL,
    LabReference STRING NOT NULL
)
AS
WITH All_Unique_Refs AS (
  -- 1. Get unique LabReferences from the Medical Records
  SELECT DISTINCT LabReference
  FROM `bigquery-tutorial-480009.A2.Medical_Records`
  WHERE LabReference IS NOT NULL
  
  UNION DISTINCT
  
  -- 2. Get unique LabReferences from the Patient Details
  SELECT DISTINCT LabReference
  FROM `bigquery-tutorial-480009.A2.MedIDDetails`
  WHERE LabReference IS NOT NULL
)

SELECT
  -- Generate a sequential ID (Surrogate Key)
  ROW_NUMBER() OVER (ORDER BY LabReference) AS ID,
  
  -- The Lab Reference Code
  LabReference
FROM
  All_Unique_Refs;