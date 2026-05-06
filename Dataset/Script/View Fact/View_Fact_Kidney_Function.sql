CREATE OR REPLACE VIEW `bigquery-tutorial-480009.A2.View_Fact_Kidney_Function` AS
SELECT 
    -- 1. Identity & Demographics
    IFNULL(m.Original_MedID, 'Unknown') AS Original_MedID,
    IFNULL(m.First_Name, 'Unknown') AS First_Name,
    IFNULL(m.Last_Name, 'Unknown') AS Last_Name,
    IFNULL(m.Gender, 'Unknown') AS Gender,
    IFNULL(m.Age_Category, 'Unknown') AS Age_Category,
    
    -- 2. Time Dimension
    c.Date AS Test_Date,
    
    -- 3. Filtration & Waste Metrics (Numerical)
    u.Creatinine,
    u.Urea,
    u.BUN,
    u.BUN_Creatinine_Ratio,
    u.eGFR, -- Estimated Glomerular Filtration Rate
    u.Uric_Acid,
    
    -- 4. Electrolyte Metrics (Numerical)
    u.Sodium,
    u.Potassium,
    u.Chloride

FROM `bigquery-tutorial-480009.A2.Fact_Kidney_Function` AS u
LEFT JOIN `bigquery-tutorial-480009.A2.MedID_Dimension` AS m 
    ON u.MedID_FK = m.ID
LEFT JOIN `bigquery-tutorial-480009.A2.Collected_Dimension` AS c 
    ON u.Collected_FK = c.ID;