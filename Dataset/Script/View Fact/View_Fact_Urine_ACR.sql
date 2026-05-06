CREATE OR REPLACE VIEW `bigquery-tutorial-480009.A2.View_Fact_Urine_ACR` AS
SELECT 
  -- Standard Dimensions
  IFNULL(P.Original_MedID, 'Unknown') AS Original_MedID,
  IFNULL(P.First_Name, 'Unknown') AS First_Name, 
  IFNULL(P.Last_Name, 'Unknown') AS Last_Name,
  IFNULL(P.Gender, 'Unknown') AS Gender,
  IFNULL(P.Age_Category, 'Unknown') AS Age_Category,
  IFNULL(D.Date, DATE('1970-01-01')) AS Test_Date,
  
  -- Metrics: Microalbuminuria Screening
  IFNULL(F.Urine_Albumin, 0.0) AS Urine_Albumin,
  IFNULL(F.Urine_Creatinine, 0.0) AS Urine_Creatinine,
  IFNULL(F.Albumin_Creatinine_Ratio, 0.0) AS Albumin_Creatinine_Ratio

FROM `bigquery-tutorial-480009.A2.Fact_Urine_ACR` F
JOIN `bigquery-tutorial-480009.A2.MedID_Dimension` P ON F.MedID_FK = P.ID
JOIN `bigquery-tutorial-480009.A2.Collected_Dimension` D ON F.Collected_FK = D.ID;