CREATE OR REPLACE VIEW `bigquery-tutorial-480009.A2.View_Fact_Platelet_Profile` AS
SELECT 
    -- 1. Identity & Demographics (from MedID_Dimension)
    IFNULL(m.Original_MedID, 'Unknown') AS Original_MedID,
    IFNULL(m.First_Name, 'Unknown') AS First_Name,
    IFNULL(m.Last_Name, 'Unknown') AS Last_Name,
    IFNULL(m.Gender, 'Unknown') AS Gender,
    IFNULL(m.Age_Category, 'Unknown') AS Age_Category,
    
    -- 2. Time Attribute (from Collected_Dimension)
    c.Date AS Test_Date,
    
    -- 3. Platelet Metrics (from Fact_Platelet_Profile)
    -- Casting to FLOAT64 ensures they work with Average aggregations in Looker Studio
    SAFE_CAST(f.Platelet_Count AS INT64) AS Platelet_Count,
    SAFE_CAST(f.MPV AS FLOAT64) AS MPV,
    SAFE_CAST(f.Platelet_RDW AS FLOAT64) AS Platelet_RDW,
    SAFE_CAST(f.PCT AS FLOAT64) AS PCT,
    SAFE_CAST(f.P_LCR AS FLOAT64) AS P_LCR,
    SAFE_CAST(f.IMG AS FLOAT64) AS IMG,
    SAFE_CAST(f.IMM AS FLOAT64) AS IMM,
    SAFE_CAST(f.IML AS FLOAT64) AS IML,
    SAFE_CAST(f.LIC AS FLOAT64) AS LIC

FROM `bigquery-tutorial-480009.A2.Fact_Platelet_Profile` AS f
-- LEFT JOIN 1: Keeps records even if MedID is missing in dimension
LEFT JOIN `bigquery-tutorial-480009.A2.MedID_Dimension` AS m 
    ON f.MedID_FK = m.ID
-- LEFT JOIN 2: Keeps records even if Date mapping is missing
LEFT JOIN `bigquery-tutorial-480009.A2.Collected_Dimension` AS c 
    ON f.Collected_FK = c.ID;