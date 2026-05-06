CREATE OR REPLACE TABLE `bigquery-tutorial-480009.A2.Time_Dimension`
(
  ID INT64 NOT NULL,
  Time TIME NOT NULL
)
AS
SELECT
  -- Auto-incremental ID (1, 2, 3...)
  ROW_NUMBER() OVER (ORDER BY Time) AS ID,
  
  -- The actual Time value (24-hour format)
  Time
FROM (
  -- Get unique Collection Times from the cleaned fact table
  SELECT DISTINCT Time
  FROM `bigquery-tutorial-480009.A2.Medical_Records_Cleaned`
  WHERE Time IS NOT NULL
);