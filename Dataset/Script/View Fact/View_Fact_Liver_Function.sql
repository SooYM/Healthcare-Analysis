CREATE OR REPLACE VIEW `bigquery-tutorial-480009.A2.View_Fact_Liver_Function` AS
SELECT 
    -- 1. Identity & Demographics
    IFNULL(m.Original_MedID, 'Unknown') AS Original_MedID,
    IFNULL(m.First_Name, 'Unknown') AS First_Name,
    IFNULL(m.Last_Name, 'Unknown') AS Last_Name,
    IFNULL(m.Gender, 'Unknown') AS Gender,
    IFNULL(m.Age_Category, 'Unknown') AS Age_Category,
    
    -- 2. Time Dimension
    c.Date AS Test_Date,
    
    -- 3. Enzyme Metrics (Damage Markers)
    u.ALP,
    u.ALT_SGPT,
    u.AST_SGOT,
    u.GGT,
    
    -- 4. Bilirubin Metrics (Excretion Markers)
    u.Bilirubin_Total,
    u.Bilirubin_Direct,
    u.Bilirubin_Indirect,
    
    -- 5. Protein Metrics (Synthesis Markers)
    u.Protein_Total,
    u.Albumin,
    u.Globulin,
    u.A_G_Ratio

FROM `bigquery-tutorial-480009.A2.Fact_Liver_Function` AS u
LEFT JOIN `bigquery-tutorial-480009.A2.MedID_Dimension` AS m 
    ON u.MedID_FK = m.ID
LEFT JOIN `bigquery-tutorial-480009.A2.Collected_Dimension` AS c 
    ON u.Collected_FK = c.ID;