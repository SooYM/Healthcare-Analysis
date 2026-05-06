CREATE OR REPLACE VIEW `bigquery-tutorial-480009.A2.View_Fact_CBC` AS
SELECT 
    -- 1. Identity & Demographics (from MedID_Dimension)
    -- IFNULL keeps the row alive even if patient details are missing
    IFNULL(m.Original_MedID, 'Unknown') AS Original_MedID,
    IFNULL(m.First_Name, 'Unknown') AS First_Name,
    IFNULL(m.Last_Name, 'Unknown') AS Last_Name,
    IFNULL(m.Gender, 'Unknown') AS Gender,
    IFNULL(m.Age_Category, 'Unknown') AS Age_Category,
    
    -- 2. Time Attribute (from Collected_Dimension)
    c.Date AS Test_Date,
    
    -- 3. Red Blood Cell Metrics (from Fact_CBC)
    f.Hemoglobin,
    f.RBC_Count,
    f.Hematocrit,
    f.MCV,
    f.MCH,
    f.MCHC,
    f.RDW_CV,
    f.RDW_SD,
    
    -- 4. White Blood Cell Metrics (from Fact_CBC)
    f.WBC_Count,
    f.Neutrophils,
    f.Lymphocytes,
    f.Eosinophils,
    f.Monocytes,
    f.Basophils,
    f.Abs_Neutrophils,
    f.Abs_Lymphocytes,
    f.Abs_Monocytes,
    f.Abs_Eosinophils,
    f.Abs_Basophils

FROM `bigquery-tutorial-480009.A2.Fact_CBC` AS f
-- LEFT JOIN 1: Keeps CBC records even if MedID is not found in dimension
LEFT JOIN `bigquery-tutorial-480009.A2.MedID_Dimension` AS m 
    ON f.MedID_FK = m.ID
-- LEFT JOIN 2: Keeps records even if Date mapping is missing
LEFT JOIN `bigquery-tutorial-480009.A2.Collected_Dimension` AS c 
    ON f.Collected_FK = c.ID;