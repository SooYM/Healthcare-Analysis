CREATE OR REPLACE VIEW `bigquery-tutorial-480009.A2.View_Fact_Iron_Profile` AS
SELECT 
    -- 1. Identity & Demographics
    IFNULL(m.Original_MedID, 'Unknown') AS Original_MedID,
    IFNULL(m.First_Name, 'Unknown') AS First_Name,
    IFNULL(m.Last_Name, 'Unknown') AS Last_Name,
    IFNULL(m.Gender, 'Unknown') AS Gender,
    IFNULL(m.Age_Category, 'Unknown') AS Age_Category,
    
    -- 2. Time Dimension
    c.Date AS Test_Date,
    
    -- 3. Iron Metrics (Fact_Iron_Profile)
    -- Cast to FLOAT64 to ensure accurate averages in charts
    SAFE_CAST(i.Iron AS FLOAT64) AS Iron, -- Serum Iron
    SAFE_CAST(i.UIBC AS FLOAT64) AS UIBC, -- Unsaturated Iron Binding Capacity
    SAFE_CAST(i.TIBC AS FLOAT64) AS TIBC, -- Total Iron Binding Capacity
    SAFE_CAST(i.Transferrin_Saturation AS FLOAT64) AS Transferrin_Saturation

FROM `bigquery-tutorial-480009.A2.Fact_Iron_Profile` AS i
LEFT JOIN `bigquery-tutorial-480009.A2.MedID_Dimension` AS m 
    ON i.MedID_FK = m.ID
LEFT JOIN `bigquery-tutorial-480009.A2.Collected_Dimension` AS c 
    ON i.Collected_FK = c.ID;