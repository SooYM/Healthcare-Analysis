CREATE OR REPLACE VIEW `bigquery-tutorial-480009.A2.View_Fact_HbA1c` AS
SELECT 
  -- Standard Dimensions
  IFNULL(P.Original_MedID, 'Unknown') AS Original_MedID,
  IFNULL(P.First_Name, 'Unknown') AS First_Name, 
  IFNULL(P.Last_Name, 'Unknown') AS Last_Name,
  IFNULL(P.Gender, 'Unknown') AS Gender,
  IFNULL(P.Age_Category, 'Unknown') AS Age_Category,
  IFNULL(D.Date, DATE('1970-01-01')) AS Test_Date,
  
  -- Metrics: Glycated Hemoglobin
  IFNULL(F.HbA1c, 0.0) AS HbA1c,
  IFNULL(F.Estimated_Avg_Glucose, 0.0) AS Estimated_Avg_Glucose,
  IFNULL(F.HbF, 0.0) AS HbF

FROM `bigquery-tutorial-480009.A2.Fact_HbA1c` F
JOIN `bigquery-tutorial-480009.A2.MedID_Dimension` P ON F.MedID_FK = P.ID
JOIN `bigquery-tutorial-480009.A2.Collected_Dimension` D ON F.Collected_FK = D.ID;