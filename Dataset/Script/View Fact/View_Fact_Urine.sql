CREATE OR REPLACE VIEW `bigquery-tutorial-480009.A2.View_Fact_Urine` AS
SELECT 
    -- 1. Identity & Demographic Attributes from MedID_Dimension
    -- IFNULL ensures records with missing metadata show as 'Unknown' instead of being deleted
    IFNULL(m.Original_MedID, 'Unknown') AS Original_MedID,
    IFNULL(m.First_Name, 'Unknown') AS First_Name,
    IFNULL(m.Last_Name, 'Unknown') AS Last_Name,
    IFNULL(m.Gender, 'Unknown') AS Gender,
    IFNULL(m.Age_Category, 'Unknown') AS Age_Category,
    
    -- 2. Time Attribute from Collected_Dimension
    c.Date AS Test_Date,
    
    -- 3. Physical Lab Results from Fact_Urine
    u.Urine_Colour,
    u.Appearance,
    
    -- 4. Chemical/Numerical Results (For OLAP Line Charts)
    u.Specific_Gravity,
    u.pH,
    
    -- 5. Screening Results (Categorical)
    u.Proteins,
    u.Glucose,
    u.Bilirubin,
    u.Ketones,
    u.Blood,
    u.Urobilinogen,
    u.Nitrites,
    
    -- 6. Microscopic Results
    u.WBC_Pus_Cells,
    u.RBC,
    u.Epithelial_Cells,
    u.Casts,
    u.Crystals,
    u.Others

FROM `bigquery-tutorial-480009.A2.Fact_Urine` AS u
-- Use LEFT JOIN to keep the 1,154 records that don't match MedID_Dimension
LEFT JOIN `bigquery-tutorial-480009.A2.MedID_Dimension` AS m 
    ON u.MedID_FK = m.ID
-- Use LEFT JOIN to ensure dates are correctly mapped without losing fact rows
LEFT JOIN `bigquery-tutorial-480009.A2.Collected_Dimension` AS c 
    ON u.Collected_FK = c.ID;