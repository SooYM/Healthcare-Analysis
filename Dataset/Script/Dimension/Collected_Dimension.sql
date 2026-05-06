CREATE OR REPLACE TABLE `bigquery-tutorial-480009.A2.Collected_Dimension`
(
  ID INT64 NOT NULL,
  Date DATE NOT NULL
)
AS
SELECT
  -- Auto-incremental ID (1, 2, 3...)
  ROW_NUMBER() OVER (ORDER BY Collected) AS ID,
  
  -- The actual Date value
  Collected AS Date
FROM (
  -- Get unique dates from the cleaned fact table
  SELECT DISTINCT Collected
  FROM `bigquery-tutorial-480009.A2.Medical_Records_Cleaned`
  WHERE Collected IS NOT NULL
);