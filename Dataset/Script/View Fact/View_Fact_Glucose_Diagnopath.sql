CREATE OR REPLACE VIEW `bigquery-tutorial-480009.A2.View_Fact_Glucose_Diagnopath` AS
SELECT 
  -- Standard Dimensions
  IFNULL(P.Original_MedID, 'Unknown') AS Original_MedID,
  IFNULL(P.First_Name, 'Unknown') AS First_Name, 
  IFNULL(P.Last_Name, 'Unknown') AS Last_Name,
  IFNULL(P.Gender, 'Unknown') AS Gender,
  IFNULL(P.Age_Category, 'Unknown') AS Age_Category,
  IFNULL(D.Date, DATE('1970-01-01')) AS Test_Date,
  
  -- Metrics: Diagnopath Glucose Tests
  IFNULL(F.FBS, 0) AS FBS,   -- Fasting Blood Sugar
  IFNULL(F.PLBS, 0) AS PLBS  -- Post-Lunch Blood Sugar

FROM `bigquery-tutorial-480009.A2.Fact_Glucose_Diagnopath` F
JOIN `bigquery-tutorial-480009.A2.MedID_Dimension` P ON F.MedID_FK = P.ID
JOIN `bigquery-tutorial-480009.A2.Collected_Dimension` D ON F.Collected_FK = D.ID;