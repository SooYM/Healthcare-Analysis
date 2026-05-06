CREATE OR REPLACE VIEW `bigquery-tutorial-480009.A2.View_Fact_Lipid_Profile` AS
SELECT 
    -- 1. Identity & Demographics
    IFNULL(m.Original_MedID, 'Unknown') AS Original_MedID,
    IFNULL(m.First_Name, 'Unknown') AS First_Name,
    IFNULL(m.Last_Name, 'Unknown') AS Last_Name,
    IFNULL(m.Gender, 'Unknown') AS Gender,
    IFNULL(m.Age_Category, 'Unknown') AS Age_Category,
    
    -- 2. Time Attribute
    c.Date AS Test_Date,
    
    -- 3. Cholesterol Metrics (Fact_Lipid_Profile)
    SAFE_CAST(l.Total_Cholesterol AS INT64) AS Total_Cholesterol,
    SAFE_CAST(l.HDL AS INT64) AS HDL, -- "Good" Cholesterol
    SAFE_CAST(l.LDL AS FLOAT64) AS LDL, -- "Bad" Cholesterol
    
    -- ⚠️ Critical Fix: Convert String to Float for Analysis
    SAFE_CAST(l.VLDL AS FLOAT64) AS VLDL,
    SAFE_CAST(l.Triglycerides AS FLOAT64) AS Triglycerides,
    
    SAFE_CAST(l.Non_HDL AS INT64) AS Non_HDL,
    
    -- 4. Risk Ratios (Critical for Dashboard Gauges)
    SAFE_CAST(l.Total_HDL_Ratio AS FLOAT64) AS Total_HDL_Ratio,
    SAFE_CAST(l.LDL_HDL_Ratio AS FLOAT64) AS LDL_HDL_Ratio,
    SAFE_CAST(l.HDL_LDL_Ratio AS FLOAT64) AS HDL_LDL_Ratio

FROM `bigquery-tutorial-480009.A2.Fact_Lipid_Profile` AS l
LEFT JOIN `bigquery-tutorial-480009.A2.MedID_Dimension` AS m 
    ON l.MedID_FK = m.ID
LEFT JOIN `bigquery-tutorial-480009.A2.Collected_Dimension` AS c 
    ON l.Collected_FK = c.ID;