CREATE OR REPLACE TABLE `bigquery-tutorial-480009.A2.MedID_Dimension`
(
  ID INT64 NOT NULL,
  Original_MedID STRING NOT NULL,
  LabReference STRING NOT NULL,
  First_Name STRING NOT NULL,
  Last_Name STRING NOT NULL,
  Age INT64 NOT NULL,
  Age_Category STRING NOT NULL,
  Gender STRING NOT NULL,
  Diet STRING NOT NULL,
  Registration_Weight FLOAT64 NOT NULL
)
AS
WITH Age_Ranges AS (
  -- Parse the text range '25-29' or '25–29' into numeric Start and End ages
  SELECT
    Category,
    -- Handling both en-dash and hyphen
    CAST(SPLIT(REPLACE(`Age_Range`, '–', '-'), '-')[OFFSET(0)] AS INT64) AS Start_Age,
    CAST(SPLIT(REPLACE(`Age_Range`, '–', '-'), '-')[OFFSET(1)] AS INT64) AS End_Age
  FROM
    `bigquery-tutorial-480009.A2.AgeCategories`
)

SELECT
  -- Generate sequential ID (Surrogate Key)
  ROW_NUMBER() OVER (ORDER BY m.MedID) AS ID,

  -- Original ID cast to String
  CAST(m.MedID AS STRING) AS Original_MedID,

  -- Use COALESCE to ensure no null values are inserted
  COALESCE(m.LabReference, 'Unknown') AS LabReference,
  COALESCE(m.`First Name`, 'Unknown') AS First_Name,
  COALESCE(m.`Last Name`, 'Unknown') AS Last_Name,
  COALESCE(m.Age, -1) AS Age,

  -- Join results from the Age_Ranges CTE
  COALESCE(a.Category, 'Unknown') AS Age_Category,

  -- Map Zender to Gender and handle nulls
  COALESCE(m.Gender, 'Unknown') AS Gender,
  COALESCE(m.Diet, 'Unknown') AS Diet,
  COALESCE(m.`Registration Weight`, 0.0) AS Registration_Weight

FROM
  `bigquery-tutorial-480009.A2.MedIDDetails` m
LEFT JOIN
  Age_Ranges a
ON
  m.Age BETWEEN a.Start_Age AND a.End_Age;