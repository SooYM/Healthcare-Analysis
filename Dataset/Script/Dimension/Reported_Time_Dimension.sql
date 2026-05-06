CREATE OR REPLACE TABLE `bigquery-tutorial-480009.A2.Reported_Time_Dimension`
(
  ID INT64 NOT NULL,
  Reported_Time TIME NOT NULL
)
AS
SELECT
  -- Auto-incremental ID (1, 2, 3...)
  ROW_NUMBER() OVER (ORDER BY `Reported Time`) AS ID,
  
  -- The actual Reported Time value
  `Reported Time` AS Reported_Time
FROM (
  -- Get unique Reported Times from the cleaned fact table
  SELECT DISTINCT `Reported Time`
  FROM `bigquery-tutorial-480009.A2.Medical_Records_Cleaned`
  WHERE `Reported Time` IS NOT NULL
);