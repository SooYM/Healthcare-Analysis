-- ============================================================================
-- Healthcare Dashboard — MySQL 8.0 Conversion
-- Converted from Google BigQuery (project: bigquery-tutorial-480009, dataset: A2)
-- Database: healthcare_dashboard
-- Generated: 2026-05-06
-- ============================================================================
-- EXECUTION ORDER:
--   1. Source Table Stubs (import CSV data via phpMyAdmin after creation)
--   2. Dimension Tables (6)
--   3. Fact Tables (14)
--   4. Views (14)
-- ============================================================================

CREATE DATABASE IF NOT EXISTS `healthcare_dashboard`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `healthcare_dashboard`;

-- ############################################################################
-- SECTION 0: SOURCE TABLE STUBS
-- Import CSV data into these tables via phpMyAdmin before running Section 1+
-- ############################################################################

CREATE TABLE IF NOT EXISTS `AgeCategories` (
  `Category` VARCHAR(50) NOT NULL,
  `Age_Range` VARCHAR(20) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `MedIDDetails` (
  `MedID` BIGINT DEFAULT NULL,
  `LabReference` VARCHAR(100) DEFAULT NULL,
  `First Name` VARCHAR(100) DEFAULT NULL,
  `Last Name` VARCHAR(100) DEFAULT NULL,
  `Age` INT DEFAULT NULL,
  `Gender` VARCHAR(20) DEFAULT NULL,
  `Diet` VARCHAR(100) DEFAULT NULL,
  `Registration Weight` DOUBLE DEFAULT NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `Medical_Records` (
  `LabReference` VARCHAR(100) DEFAULT NULL
  -- Add remaining columns as needed for your dataset
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `Medical_Records_Cleaned` (
  `MedID` BIGINT DEFAULT NULL,
  `LabReference` VARCHAR(100) DEFAULT NULL,
  `Sample ID` BIGINT DEFAULT NULL,
  `Collected` DATE DEFAULT NULL,
  `Time` TIME DEFAULT NULL,
  `Reported Time` TIME DEFAULT NULL,
  -- Urine
  `Urine Colour` VARCHAR(100) DEFAULT NULL,
  `Appearance` VARCHAR(100) DEFAULT NULL,
  `Specific Gravity` DOUBLE DEFAULT NULL,
  `pH` DOUBLE DEFAULT NULL,
  `Proteins` VARCHAR(100) DEFAULT NULL,
  `Glucose` VARCHAR(100) DEFAULT NULL,
  `Bilirubin` VARCHAR(100) DEFAULT NULL,
  `Ketones` VARCHAR(100) DEFAULT NULL,
  `Blood` VARCHAR(100) DEFAULT NULL,
  `Urobilinogen` VARCHAR(100) DEFAULT NULL,
  `Nitrites` VARCHAR(100) DEFAULT NULL,
  `WBC _Pus Cells_ __HPF_` VARCHAR(100) DEFAULT NULL,
  `RBC` VARCHAR(100) DEFAULT NULL,
  `Epithelial Cells __HPF_` VARCHAR(100) DEFAULT NULL,
  `Casts` VARCHAR(100) DEFAULT NULL,
  `Crystals` VARCHAR(100) DEFAULT NULL,
  `Others` VARCHAR(100) DEFAULT NULL,
  -- CBC
  `Hemoglobin _g_dL_` DOUBLE DEFAULT NULL,
  `RBC Count _mil_µL_` DOUBLE DEFAULT NULL,
  `Hematocrit %` DOUBLE DEFAULT NULL,
  `MCV _fL_` DOUBLE DEFAULT NULL,
  `MCH _pg_` BIGINT DEFAULT NULL,
  `MCHC _g_dL_` DOUBLE DEFAULT NULL,
  `RDW-CV %` DOUBLE DEFAULT NULL,
  `RDW-SD _fL_` DOUBLE DEFAULT NULL,
  `WBC _cells_µL_` BIGINT DEFAULT NULL,
  `Neutrophils %` BIGINT DEFAULT NULL,
  `Lymphocytes %` BIGINT DEFAULT NULL,
  `Eosinophils %` BIGINT DEFAULT NULL,
  `Monocytes %` BIGINT DEFAULT NULL,
  `Basophils %` DOUBLE DEFAULT NULL,
  `Abs Neutrophils` DOUBLE DEFAULT NULL,
  `Abs Lymphocytes` DOUBLE DEFAULT NULL,
  `Abs Monocytes` DOUBLE DEFAULT NULL,
  `Abs Eosinophils` DOUBLE DEFAULT NULL,
  `Abs Basophils` DOUBLE DEFAULT NULL,
  -- Platelet
  `Platelet Count __10_3_µL_` BIGINT DEFAULT NULL,
  `MPV _fL_` DOUBLE DEFAULT NULL,
  `Platelet RDW %` BIGINT DEFAULT NULL,
  `PCT %` DOUBLE DEFAULT NULL,
  `P-LCR %` DOUBLE DEFAULT NULL,
  `IMG %` DOUBLE DEFAULT NULL,
  `IMM %` DOUBLE DEFAULT NULL,
  `IML %` DOUBLE DEFAULT NULL,
  `LIC %` DOUBLE DEFAULT NULL,
  -- Lipid Profile
  `Total Cholesterol _mg_dL_` BIGINT DEFAULT NULL,
  `HDL _mg_dL_` BIGINT DEFAULT NULL,
  `LDL _mg_dL_` DOUBLE DEFAULT NULL,
  `VLDL _mg_dL_` VARCHAR(100) DEFAULT NULL,
  `Triglycerides _mg_dL_` VARCHAR(100) DEFAULT NULL,
  `Non-HDL _mg_dL_` BIGINT DEFAULT NULL,
  `Total_HDL Ratio` DOUBLE DEFAULT NULL,
  `LDL_HDL Ratio` DOUBLE DEFAULT NULL,
  `HDL_LDL Ratio` DOUBLE DEFAULT NULL,
  -- Liver Function
  `Bilirubin Total _mg_dL_` DOUBLE DEFAULT NULL,
  `Bilirubin Direct _mg_dL_` DOUBLE DEFAULT NULL,
  `Bilirubin Indirect _mg_dL_` DOUBLE DEFAULT NULL,
  `ALP _U_L_` BIGINT DEFAULT NULL,
  `ALT_SGPT _U_L_` BIGINT DEFAULT NULL,
  `AST_SGOT _U_L_` BIGINT DEFAULT NULL,
  `GGT _U_L_` BIGINT DEFAULT NULL,
  `Protein Total _g_dL_` DOUBLE DEFAULT NULL,
  `Albumin _g_dL_` DOUBLE DEFAULT NULL,
  `Globulin _g_dL_` DOUBLE DEFAULT NULL,
  `A_G Ratio` VARCHAR(100) DEFAULT NULL,
  -- Kidney Function
  `Creatinine _mg_dL_` DOUBLE DEFAULT NULL,
  `Urea _mg_dL_` DOUBLE DEFAULT NULL,
  `BUN _mg_dL_` DOUBLE DEFAULT NULL,
  `BUN_Creatinine Ratio` DOUBLE DEFAULT NULL,
  `Sodium _mmol_L_` BIGINT DEFAULT NULL,
  `Potassium _mmol_L_` DOUBLE DEFAULT NULL,
  `Chloride _mmol_L_` BIGINT DEFAULT NULL,
  `Uric Acid _mg_dL_` DOUBLE DEFAULT NULL,
  `eGFR _mL_min_1_73m²_` DOUBLE DEFAULT NULL,
  -- Iron Profile
  `Iron _µg_dL_` BIGINT DEFAULT NULL,
  `UIBC _µg_dL_` BIGINT DEFAULT NULL,
  `TIBC _µg_dL_` BIGINT DEFAULT NULL,
  `Transferrin Saturation %` DOUBLE DEFAULT NULL,
  -- HbA1c
  `HbA1c %` DOUBLE DEFAULT NULL,
  `Estimated Avg Glucose _mg_dL_` DOUBLE DEFAULT NULL,
  `HbF %` DOUBLE DEFAULT NULL,
  -- Urine ACR
  `Urine Albumin _mg_L_` DOUBLE DEFAULT NULL,
  `Urine Creatinine _mg_dL_` DOUBLE DEFAULT NULL,
  `Albumin_Creatinine Ratio` DOUBLE DEFAULT NULL,
  -- Calcium & Phosphorus
  `Calcium _mg_dL_` DOUBLE DEFAULT NULL,
  `Phosphorus _mg_dL_` DOUBLE DEFAULT NULL,
  -- Thyroid
  `TT3 _ng_dL_` BIGINT DEFAULT NULL,
  `TT4 _µg_dL_` DOUBLE DEFAULT NULL,
  `TSH _µIU_mL_` DOUBLE DEFAULT NULL,
  -- Glucose
  `Fasting Glucose _mg_dL_` BIGINT DEFAULT NULL,
  `Postprandial Glucose _mg_dL_` BIGINT DEFAULT NULL,
  `FBS _mg_dL_` BIGINT DEFAULT NULL,
  `PLBS _mg_dL_` BIGINT DEFAULT NULL
) ENGINE=InnoDB;


-- ############################################################################
-- SECTION 1: DIMENSION TABLES (6)
-- ############################################################################

-- --------------------------------------------------------------------------
-- 1.1 MedID_Dimension
-- --------------------------------------------------------------------------
DROP TABLE IF EXISTS `MedID_Dimension`;
CREATE TABLE `MedID_Dimension` (
  `ID` BIGINT NOT NULL,
  `Original_MedID` VARCHAR(255) NOT NULL,
  `LabReference` VARCHAR(255) NOT NULL,
  `First_Name` VARCHAR(255) NOT NULL,
  `Last_Name` VARCHAR(255) NOT NULL,
  `Age` BIGINT NOT NULL,
  `Age_Category` VARCHAR(255) NOT NULL,
  `Gender` VARCHAR(255) NOT NULL,
  `Diet` VARCHAR(255) NOT NULL,
  `Registration_Weight` DOUBLE NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB;

INSERT INTO `MedID_Dimension`
  (`ID`, `Original_MedID`, `LabReference`, `First_Name`, `Last_Name`,
   `Age`, `Age_Category`, `Gender`, `Diet`, `Registration_Weight`)
WITH Age_Ranges AS (
  SELECT
    `Category`,
    CAST(SUBSTRING_INDEX(REPLACE(`Age_Range`, '–', '-'), '-', 1) AS SIGNED) AS Start_Age,
    CAST(SUBSTRING_INDEX(REPLACE(`Age_Range`, '–', '-'), '-', -1) AS SIGNED) AS End_Age
  FROM `AgeCategories`
)
SELECT
  ROW_NUMBER() OVER (ORDER BY m.`MedID`) AS ID,
  CAST(m.`MedID` AS CHAR) AS Original_MedID,
  COALESCE(m.`LabReference`, 'Unknown') AS LabReference,
  COALESCE(m.`First Name`, 'Unknown') AS First_Name,
  COALESCE(m.`Last Name`, 'Unknown') AS Last_Name,
  COALESCE(m.`Age`, -1) AS Age,
  COALESCE(a.`Category`, 'Unknown') AS Age_Category,
  COALESCE(m.`Gender`, 'Unknown') AS Gender,
  COALESCE(m.`Diet`, 'Unknown') AS Diet,
  COALESCE(m.`Registration Weight`, 0.0) AS Registration_Weight
FROM `MedIDDetails` m
LEFT JOIN Age_Ranges a
  ON m.`Age` BETWEEN a.Start_Age AND a.End_Age;


-- --------------------------------------------------------------------------
-- 1.2 LabReference_Dimension
-- --------------------------------------------------------------------------
DROP TABLE IF EXISTS `LabReference_Dimension`;
CREATE TABLE `LabReference_Dimension` (
  `ID` BIGINT NOT NULL,
  `LabReference` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB;

INSERT INTO `LabReference_Dimension` (`ID`, `LabReference`)
WITH All_Unique_Refs AS (
  SELECT DISTINCT `LabReference`
  FROM `Medical_Records`
  WHERE `LabReference` IS NOT NULL
  UNION DISTINCT
  SELECT DISTINCT `LabReference`
  FROM `MedIDDetails`
  WHERE `LabReference` IS NOT NULL
)
SELECT
  ROW_NUMBER() OVER (ORDER BY `LabReference`) AS ID,
  `LabReference`
FROM All_Unique_Refs;


-- --------------------------------------------------------------------------
-- 1.3 SampleID_Dimension
-- --------------------------------------------------------------------------
DROP TABLE IF EXISTS `SampleID_Dimension`;
CREATE TABLE `SampleID_Dimension` (
  `ID` BIGINT NOT NULL,
  `Sample_ID` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB;

INSERT INTO `SampleID_Dimension` (`ID`, `Sample_ID`)
SELECT
  ROW_NUMBER() OVER (ORDER BY `Sample ID`) AS ID,
  CAST(`Sample ID` AS CHAR) AS Sample_ID
FROM (
  SELECT DISTINCT `Sample ID`
  FROM `Medical_Records_Cleaned`
  WHERE `Sample ID` IS NOT NULL
) sub;


-- --------------------------------------------------------------------------
-- 1.4 Collected_Dimension
-- --------------------------------------------------------------------------
DROP TABLE IF EXISTS `Collected_Dimension`;
CREATE TABLE `Collected_Dimension` (
  `ID` BIGINT NOT NULL,
  `Date` DATE NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB;

INSERT INTO `Collected_Dimension` (`ID`, `Date`)
SELECT
  ROW_NUMBER() OVER (ORDER BY `Collected`) AS ID,
  `Collected` AS `Date`
FROM (
  SELECT DISTINCT `Collected`
  FROM `Medical_Records_Cleaned`
  WHERE `Collected` IS NOT NULL
) sub;


-- --------------------------------------------------------------------------
-- 1.5 Time_Dimension
-- --------------------------------------------------------------------------
DROP TABLE IF EXISTS `Time_Dimension`;
CREATE TABLE `Time_Dimension` (
  `ID` BIGINT NOT NULL,
  `Time` TIME NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB;

INSERT INTO `Time_Dimension` (`ID`, `Time`)
SELECT
  ROW_NUMBER() OVER (ORDER BY `Time`) AS ID,
  `Time`
FROM (
  SELECT DISTINCT `Time`
  FROM `Medical_Records_Cleaned`
  WHERE `Time` IS NOT NULL
) sub;


-- --------------------------------------------------------------------------
-- 1.6 Reported_Time_Dimension
-- --------------------------------------------------------------------------
DROP TABLE IF EXISTS `Reported_Time_Dimension`;
CREATE TABLE `Reported_Time_Dimension` (
  `ID` BIGINT NOT NULL,
  `Reported_Time` TIME NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB;

INSERT INTO `Reported_Time_Dimension` (`ID`, `Reported_Time`)
SELECT
  ROW_NUMBER() OVER (ORDER BY `Reported Time`) AS ID,
  `Reported Time` AS Reported_Time
FROM (
  SELECT DISTINCT `Reported Time`
  FROM `Medical_Records_Cleaned`
  WHERE `Reported Time` IS NOT NULL
) sub;


-- ############################################################################
-- SECTION 2: FACT TABLES (14)
-- All fact tables share the same 6 foreign key columns + domain measures.
-- The JOIN pattern to resolve FKs is identical across all fact tables.
-- ############################################################################

-- --------------------------------------------------------------------------
-- 2.1 Fact_Urine
-- --------------------------------------------------------------------------
DROP TABLE IF EXISTS `Fact_Urine`;
CREATE TABLE `Fact_Urine` (
  `MedID_FK` BIGINT NOT NULL,
  `LabReference_FK` BIGINT NOT NULL,
  `SampleID_FK` BIGINT NOT NULL,
  `Collected_FK` BIGINT NOT NULL,
  `Time_FK` BIGINT NOT NULL,
  `Reported_Time_FK` BIGINT NOT NULL,
  `Urine_Colour` VARCHAR(255) NOT NULL,
  `Appearance` VARCHAR(255) NOT NULL,
  `Specific_Gravity` DOUBLE NOT NULL,
  `pH` DOUBLE NOT NULL,
  `Proteins` VARCHAR(255) NOT NULL,
  `Glucose` VARCHAR(255) NOT NULL,
  `Bilirubin` VARCHAR(255) NOT NULL,
  `Ketones` VARCHAR(255) NOT NULL,
  `Blood` VARCHAR(255) NOT NULL,
  `Urobilinogen` VARCHAR(255) NOT NULL,
  `Nitrites` VARCHAR(255) NOT NULL,
  `WBC_Pus_Cells` VARCHAR(255) NOT NULL,
  `RBC` VARCHAR(255) NOT NULL,
  `Epithelial_Cells` VARCHAR(255) NOT NULL,
  `Casts` VARCHAR(255) NOT NULL,
  `Crystals` VARCHAR(255) NOT NULL,
  `Others` VARCHAR(255) NOT NULL
) ENGINE=InnoDB;

INSERT INTO `Fact_Urine`
SELECT
  COALESCE(d_med.ID, -1) AS MedID_FK,
  COALESCE(d_lab.ID, -1) AS LabReference_FK,
  COALESCE(d_samp.ID, -1) AS SampleID_FK,
  COALESCE(d_coll.ID, -1) AS Collected_FK,
  COALESCE(d_time.ID, -1) AS Time_FK,
  COALESCE(d_rep.ID, -1) AS Reported_Time_FK,
  COALESCE(f.`Urine Colour`, 'Unknown') AS Urine_Colour,
  COALESCE(f.`Appearance`, 'Unknown') AS Appearance,
  COALESCE(f.`Specific Gravity`, 0.0) AS Specific_Gravity,
  COALESCE(f.`pH`, 0.0) AS pH,
  COALESCE(f.`Proteins`, 'Unknown') AS Proteins,
  COALESCE(f.`Glucose`, 'Unknown') AS Glucose,
  COALESCE(f.`Bilirubin`, 'Unknown') AS Bilirubin,
  COALESCE(f.`Ketones`, 'Unknown') AS Ketones,
  COALESCE(f.`Blood`, 'Unknown') AS Blood,
  COALESCE(f.`Urobilinogen`, 'Unknown') AS Urobilinogen,
  COALESCE(f.`Nitrites`, 'Unknown') AS Nitrites,
  COALESCE(f.`WBC _Pus Cells_ __HPF_`, 'Unknown') AS WBC_Pus_Cells,
  COALESCE(f.`RBC`, 'Unknown') AS RBC,
  COALESCE(f.`Epithelial Cells __HPF_`, 'Unknown') AS Epithelial_Cells,
  COALESCE(f.`Casts`, 'Unknown') AS Casts,
  COALESCE(f.`Crystals`, 'Unknown') AS Crystals,
  COALESCE(f.`Others`, 'Unknown') AS Others
FROM `Medical_Records_Cleaned` f
LEFT JOIN `MedID_Dimension` d_med ON CAST(f.`MedID` AS CHAR) = d_med.`Original_MedID`
LEFT JOIN `LabReference_Dimension` d_lab ON f.`LabReference` = d_lab.`LabReference`
LEFT JOIN `SampleID_Dimension` d_samp ON CAST(f.`Sample ID` AS CHAR) = d_samp.`Sample_ID`
LEFT JOIN `Collected_Dimension` d_coll ON f.`Collected` = d_coll.`Date`
LEFT JOIN `Time_Dimension` d_time ON f.`Time` = d_time.`Time`
LEFT JOIN `Reported_Time_Dimension` d_rep ON f.`Reported Time` = d_rep.`Reported_Time`;


-- --------------------------------------------------------------------------
-- 2.2 Fact_CBC
-- --------------------------------------------------------------------------
DROP TABLE IF EXISTS `Fact_CBC`;
CREATE TABLE `Fact_CBC` (
  `MedID_FK` BIGINT NOT NULL,
  `LabReference_FK` BIGINT NOT NULL,
  `SampleID_FK` BIGINT NOT NULL,
  `Collected_FK` BIGINT NOT NULL,
  `Time_FK` BIGINT NOT NULL,
  `Reported_Time_FK` BIGINT NOT NULL,
  `Hemoglobin` DOUBLE NOT NULL,
  `RBC_Count` DOUBLE NOT NULL,
  `Hematocrit` DOUBLE NOT NULL,
  `MCV` DOUBLE NOT NULL,
  `MCH` BIGINT NOT NULL,
  `MCHC` DOUBLE NOT NULL,
  `RDW_CV` DOUBLE NOT NULL,
  `RDW_SD` DOUBLE NOT NULL,
  `WBC_Count` BIGINT NOT NULL,
  `Neutrophils` BIGINT NOT NULL,
  `Lymphocytes` BIGINT NOT NULL,
  `Eosinophils` BIGINT NOT NULL,
  `Monocytes` BIGINT NOT NULL,
  `Basophils` DOUBLE NOT NULL,
  `Abs_Neutrophils` DOUBLE NOT NULL,
  `Abs_Lymphocytes` DOUBLE NOT NULL,
  `Abs_Monocytes` DOUBLE NOT NULL,
  `Abs_Eosinophils` DOUBLE NOT NULL,
  `Abs_Basophils` DOUBLE NOT NULL
) ENGINE=InnoDB;

INSERT INTO `Fact_CBC`
SELECT
  COALESCE(d_med.ID, -1), COALESCE(d_lab.ID, -1), COALESCE(d_samp.ID, -1),
  COALESCE(d_coll.ID, -1), COALESCE(d_time.ID, -1), COALESCE(d_rep.ID, -1),
  COALESCE(f.`Hemoglobin _g_dL_`, 0.0),
  COALESCE(f.`RBC Count _mil_µL_`, 0.0),
  COALESCE(f.`Hematocrit %`, 0.0),
  COALESCE(f.`MCV _fL_`, 0.0),
  COALESCE(f.`MCH _pg_`, 0),
  COALESCE(f.`MCHC _g_dL_`, 0.0),
  COALESCE(f.`RDW-CV %`, 0.0),
  COALESCE(f.`RDW-SD _fL_`, 0.0),
  COALESCE(f.`WBC _cells_µL_`, 0),
  COALESCE(f.`Neutrophils %`, 0),
  COALESCE(f.`Lymphocytes %`, 0),
  COALESCE(f.`Eosinophils %`, 0),
  COALESCE(f.`Monocytes %`, 0),
  COALESCE(f.`Basophils %`, 0.0),
  COALESCE(f.`Abs Neutrophils`, 0.0),
  COALESCE(f.`Abs Lymphocytes`, 0.0),
  COALESCE(f.`Abs Monocytes`, 0.0),
  COALESCE(f.`Abs Eosinophils`, 0.0),
  COALESCE(f.`Abs Basophils`, 0.0)
FROM `Medical_Records_Cleaned` f
LEFT JOIN `MedID_Dimension` d_med ON CAST(f.`MedID` AS CHAR) = d_med.`Original_MedID`
LEFT JOIN `LabReference_Dimension` d_lab ON f.`LabReference` = d_lab.`LabReference`
LEFT JOIN `SampleID_Dimension` d_samp ON CAST(f.`Sample ID` AS CHAR) = d_samp.`Sample_ID`
LEFT JOIN `Collected_Dimension` d_coll ON f.`Collected` = d_coll.`Date`
LEFT JOIN `Time_Dimension` d_time ON f.`Time` = d_time.`Time`
LEFT JOIN `Reported_Time_Dimension` d_rep ON f.`Reported Time` = d_rep.`Reported_Time`;


-- --------------------------------------------------------------------------
-- 2.3 Fact_Platelet_Profile
-- --------------------------------------------------------------------------
DROP TABLE IF EXISTS `Fact_Platelet_Profile`;
CREATE TABLE `Fact_Platelet_Profile` (
  `MedID_FK` BIGINT NOT NULL, `LabReference_FK` BIGINT NOT NULL,
  `SampleID_FK` BIGINT NOT NULL, `Collected_FK` BIGINT NOT NULL,
  `Time_FK` BIGINT NOT NULL, `Reported_Time_FK` BIGINT NOT NULL,
  `Platelet_Count` BIGINT NOT NULL, `MPV` DOUBLE NOT NULL,
  `Platelet_RDW` BIGINT NOT NULL, `PCT` DOUBLE NOT NULL,
  `P_LCR` DOUBLE NOT NULL, `IMG` DOUBLE NOT NULL,
  `IMM` DOUBLE NOT NULL, `IML` DOUBLE NOT NULL, `LIC` DOUBLE NOT NULL
) ENGINE=InnoDB;

INSERT INTO `Fact_Platelet_Profile`
SELECT
  COALESCE(d_med.ID, -1), COALESCE(d_lab.ID, -1), COALESCE(d_samp.ID, -1),
  COALESCE(d_coll.ID, -1), COALESCE(d_time.ID, -1), COALESCE(d_rep.ID, -1),
  COALESCE(f.`Platelet Count __10_3_µL_`, 0),
  COALESCE(f.`MPV _fL_`, 0.0),
  COALESCE(f.`Platelet RDW %`, 0),
  COALESCE(f.`PCT %`, 0.0),
  COALESCE(f.`P-LCR %`, 0.0),
  COALESCE(f.`IMG %`, 0.0),
  COALESCE(f.`IMM %`, 0.0),
  COALESCE(f.`IML %`, 0.0),
  COALESCE(f.`LIC %`, 0.0)
FROM `Medical_Records_Cleaned` f
LEFT JOIN `MedID_Dimension` d_med ON CAST(f.`MedID` AS CHAR) = d_med.`Original_MedID`
LEFT JOIN `LabReference_Dimension` d_lab ON f.`LabReference` = d_lab.`LabReference`
LEFT JOIN `SampleID_Dimension` d_samp ON CAST(f.`Sample ID` AS CHAR) = d_samp.`Sample_ID`
LEFT JOIN `Collected_Dimension` d_coll ON f.`Collected` = d_coll.`Date`
LEFT JOIN `Time_Dimension` d_time ON f.`Time` = d_time.`Time`
LEFT JOIN `Reported_Time_Dimension` d_rep ON f.`Reported Time` = d_rep.`Reported_Time`;


-- --------------------------------------------------------------------------
-- 2.4 Fact_Lipid_Profile
-- --------------------------------------------------------------------------
DROP TABLE IF EXISTS `Fact_Lipid_Profile`;
CREATE TABLE `Fact_Lipid_Profile` (
  `MedID_FK` BIGINT NOT NULL, `LabReference_FK` BIGINT NOT NULL,
  `SampleID_FK` BIGINT NOT NULL, `Collected_FK` BIGINT NOT NULL,
  `Time_FK` BIGINT NOT NULL, `Reported_Time_FK` BIGINT NOT NULL,
  `Total_Cholesterol` BIGINT NOT NULL, `HDL` BIGINT NOT NULL,
  `LDL` DOUBLE NOT NULL,
  `VLDL` VARCHAR(255) NOT NULL,
  `Triglycerides` VARCHAR(255) NOT NULL,
  `Non_HDL` BIGINT NOT NULL,
  `Total_HDL_Ratio` DOUBLE NOT NULL, `LDL_HDL_Ratio` DOUBLE NOT NULL,
  `HDL_LDL_Ratio` DOUBLE NOT NULL
) ENGINE=InnoDB;

INSERT INTO `Fact_Lipid_Profile`
SELECT
  COALESCE(d_med.ID, -1), COALESCE(d_lab.ID, -1), COALESCE(d_samp.ID, -1),
  COALESCE(d_coll.ID, -1), COALESCE(d_time.ID, -1), COALESCE(d_rep.ID, -1),
  COALESCE(f.`Total Cholesterol _mg_dL_`, 0),
  COALESCE(f.`HDL _mg_dL_`, 0),
  COALESCE(f.`LDL _mg_dL_`, 0.0),
  COALESCE(f.`VLDL _mg_dL_`, 'Unknown'),
  COALESCE(f.`Triglycerides _mg_dL_`, 'Unknown'),
  COALESCE(f.`Non-HDL _mg_dL_`, 0),
  COALESCE(f.`Total_HDL Ratio`, 0.0),
  COALESCE(f.`LDL_HDL Ratio`, 0.0),
  COALESCE(f.`HDL_LDL Ratio`, 0.0)
FROM `Medical_Records_Cleaned` f
LEFT JOIN `MedID_Dimension` d_med ON CAST(f.`MedID` AS CHAR) = d_med.`Original_MedID`
LEFT JOIN `LabReference_Dimension` d_lab ON f.`LabReference` = d_lab.`LabReference`
LEFT JOIN `SampleID_Dimension` d_samp ON CAST(f.`Sample ID` AS CHAR) = d_samp.`Sample_ID`
LEFT JOIN `Collected_Dimension` d_coll ON f.`Collected` = d_coll.`Date`
LEFT JOIN `Time_Dimension` d_time ON f.`Time` = d_time.`Time`
LEFT JOIN `Reported_Time_Dimension` d_rep ON f.`Reported Time` = d_rep.`Reported_Time`;


-- --------------------------------------------------------------------------
-- 2.5 Fact_Liver_Function
-- --------------------------------------------------------------------------
DROP TABLE IF EXISTS `Fact_Liver_Function`;
CREATE TABLE `Fact_Liver_Function` (
  `MedID_FK` BIGINT NOT NULL, `LabReference_FK` BIGINT NOT NULL,
  `SampleID_FK` BIGINT NOT NULL, `Collected_FK` BIGINT NOT NULL,
  `Time_FK` BIGINT NOT NULL, `Reported_Time_FK` BIGINT NOT NULL,
  `Bilirubin_Total` DOUBLE NOT NULL, `Bilirubin_Direct` DOUBLE NOT NULL,
  `Bilirubin_Indirect` DOUBLE NOT NULL, `ALP` BIGINT NOT NULL,
  `ALT_SGPT` BIGINT NOT NULL, `AST_SGOT` BIGINT NOT NULL,
  `GGT` BIGINT NOT NULL, `Protein_Total` DOUBLE NOT NULL,
  `Albumin` DOUBLE NOT NULL, `Globulin` DOUBLE NOT NULL,
  `A_G_Ratio` DOUBLE NOT NULL
) ENGINE=InnoDB;

INSERT INTO `Fact_Liver_Function`
SELECT
  COALESCE(d_med.ID, -1), COALESCE(d_lab.ID, -1), COALESCE(d_samp.ID, -1),
  COALESCE(d_coll.ID, -1), COALESCE(d_time.ID, -1), COALESCE(d_rep.ID, -1),
  COALESCE(f.`Bilirubin Total _mg_dL_`, 0.0),
  COALESCE(f.`Bilirubin Direct _mg_dL_`, 0.0),
  COALESCE(f.`Bilirubin Indirect _mg_dL_`, 0.0),
  COALESCE(f.`ALP _U_L_`, 0),
  COALESCE(f.`ALT_SGPT _U_L_`, 0),
  COALESCE(f.`AST_SGOT _U_L_`, 0),
  COALESCE(f.`GGT _U_L_`, 0),
  COALESCE(f.`Protein Total _g_dL_`, 0.0),
  COALESCE(f.`Albumin _g_dL_`, 0.0),
  COALESCE(f.`Globulin _g_dL_`, 0.0),
  COALESCE(CAST(f.`A_G Ratio` AS DOUBLE), 0.0)
FROM `Medical_Records_Cleaned` f
LEFT JOIN `MedID_Dimension` d_med ON CAST(f.`MedID` AS CHAR) = d_med.`Original_MedID`
LEFT JOIN `LabReference_Dimension` d_lab ON f.`LabReference` = d_lab.`LabReference`
LEFT JOIN `SampleID_Dimension` d_samp ON CAST(f.`Sample ID` AS CHAR) = d_samp.`Sample_ID`
LEFT JOIN `Collected_Dimension` d_coll ON f.`Collected` = d_coll.`Date`
LEFT JOIN `Time_Dimension` d_time ON f.`Time` = d_time.`Time`
LEFT JOIN `Reported_Time_Dimension` d_rep ON f.`Reported Time` = d_rep.`Reported_Time`;


-- --------------------------------------------------------------------------
-- 2.6 Fact_Kidney_Function
-- --------------------------------------------------------------------------
DROP TABLE IF EXISTS `Fact_Kidney_Function`;
CREATE TABLE `Fact_Kidney_Function` (
  `MedID_FK` BIGINT NOT NULL, `LabReference_FK` BIGINT NOT NULL,
  `SampleID_FK` BIGINT NOT NULL, `Collected_FK` BIGINT NOT NULL,
  `Time_FK` BIGINT NOT NULL, `Reported_Time_FK` BIGINT NOT NULL,
  `Creatinine` DOUBLE NOT NULL, `Urea` DOUBLE NOT NULL,
  `BUN` DOUBLE NOT NULL, `BUN_Creatinine_Ratio` DOUBLE NOT NULL,
  `Sodium` BIGINT NOT NULL, `Potassium` DOUBLE NOT NULL,
  `Chloride` BIGINT NOT NULL, `Uric_Acid` DOUBLE NOT NULL,
  `eGFR` DOUBLE NOT NULL
) ENGINE=InnoDB;

INSERT INTO `Fact_Kidney_Function`
SELECT
  COALESCE(d_med.ID, -1), COALESCE(d_lab.ID, -1), COALESCE(d_samp.ID, -1),
  COALESCE(d_coll.ID, -1), COALESCE(d_time.ID, -1), COALESCE(d_rep.ID, -1),
  COALESCE(f.`Creatinine _mg_dL_`, 0.0),
  COALESCE(f.`Urea _mg_dL_`, 0.0),
  COALESCE(f.`BUN _mg_dL_`, 0.0),
  COALESCE(f.`BUN_Creatinine Ratio`, 0.0),
  COALESCE(f.`Sodium _mmol_L_`, 0),
  COALESCE(f.`Potassium _mmol_L_`, 0.0),
  COALESCE(f.`Chloride _mmol_L_`, 0),
  COALESCE(f.`Uric Acid _mg_dL_`, 0.0),
  COALESCE(f.`eGFR _mL_min_1_73m²_`, 0.0)
FROM `Medical_Records_Cleaned` f
LEFT JOIN `MedID_Dimension` d_med ON CAST(f.`MedID` AS CHAR) = d_med.`Original_MedID`
LEFT JOIN `LabReference_Dimension` d_lab ON f.`LabReference` = d_lab.`LabReference`
LEFT JOIN `SampleID_Dimension` d_samp ON CAST(f.`Sample ID` AS CHAR) = d_samp.`Sample_ID`
LEFT JOIN `Collected_Dimension` d_coll ON f.`Collected` = d_coll.`Date`
LEFT JOIN `Time_Dimension` d_time ON f.`Time` = d_time.`Time`
LEFT JOIN `Reported_Time_Dimension` d_rep ON f.`Reported Time` = d_rep.`Reported_Time`;


-- --------------------------------------------------------------------------
-- 2.7 Fact_Iron_Profile
-- --------------------------------------------------------------------------
DROP TABLE IF EXISTS `Fact_Iron_Profile`;
CREATE TABLE `Fact_Iron_Profile` (
  `MedID_FK` BIGINT NOT NULL, `LabReference_FK` BIGINT NOT NULL,
  `SampleID_FK` BIGINT NOT NULL, `Collected_FK` BIGINT NOT NULL,
  `Time_FK` BIGINT NOT NULL, `Reported_Time_FK` BIGINT NOT NULL,
  `Iron` BIGINT NOT NULL, `UIBC` BIGINT NOT NULL,
  `TIBC` BIGINT NOT NULL, `Transferrin_Saturation` DOUBLE NOT NULL
) ENGINE=InnoDB;

INSERT INTO `Fact_Iron_Profile`
SELECT
  COALESCE(d_med.ID, -1), COALESCE(d_lab.ID, -1), COALESCE(d_samp.ID, -1),
  COALESCE(d_coll.ID, -1), COALESCE(d_time.ID, -1), COALESCE(d_rep.ID, -1),
  COALESCE(f.`Iron _µg_dL_`, 0),
  COALESCE(f.`UIBC _µg_dL_`, 0),
  COALESCE(f.`TIBC _µg_dL_`, 0),
  COALESCE(f.`Transferrin Saturation %`, 0.0)
FROM `Medical_Records_Cleaned` f
LEFT JOIN `MedID_Dimension` d_med ON CAST(f.`MedID` AS CHAR) = d_med.`Original_MedID`
LEFT JOIN `LabReference_Dimension` d_lab ON f.`LabReference` = d_lab.`LabReference`
LEFT JOIN `SampleID_Dimension` d_samp ON CAST(f.`Sample ID` AS CHAR) = d_samp.`Sample_ID`
LEFT JOIN `Collected_Dimension` d_coll ON f.`Collected` = d_coll.`Date`
LEFT JOIN `Time_Dimension` d_time ON f.`Time` = d_time.`Time`
LEFT JOIN `Reported_Time_Dimension` d_rep ON f.`Reported Time` = d_rep.`Reported_Time`;


-- --------------------------------------------------------------------------
-- 2.8 Fact_HbA1c
-- --------------------------------------------------------------------------
DROP TABLE IF EXISTS `Fact_HbA1c`;
CREATE TABLE `Fact_HbA1c` (
  `MedID_FK` BIGINT NOT NULL, `LabReference_FK` BIGINT NOT NULL,
  `SampleID_FK` BIGINT NOT NULL, `Collected_FK` BIGINT NOT NULL,
  `Time_FK` BIGINT NOT NULL, `Reported_Time_FK` BIGINT NOT NULL,
  `HbA1c` DOUBLE NOT NULL, `Estimated_Avg_Glucose` DOUBLE NOT NULL,
  `HbF` DOUBLE NOT NULL
) ENGINE=InnoDB;

INSERT INTO `Fact_HbA1c`
SELECT
  COALESCE(d_med.ID, -1), COALESCE(d_lab.ID, -1), COALESCE(d_samp.ID, -1),
  COALESCE(d_coll.ID, -1), COALESCE(d_time.ID, -1), COALESCE(d_rep.ID, -1),
  COALESCE(f.`HbA1c %`, 0.0),
  COALESCE(f.`Estimated Avg Glucose _mg_dL_`, 0.0),
  COALESCE(f.`HbF %`, 0.0)
FROM `Medical_Records_Cleaned` f
LEFT JOIN `MedID_Dimension` d_med ON CAST(f.`MedID` AS CHAR) = d_med.`Original_MedID`
LEFT JOIN `LabReference_Dimension` d_lab ON f.`LabReference` = d_lab.`LabReference`
LEFT JOIN `SampleID_Dimension` d_samp ON CAST(f.`Sample ID` AS CHAR) = d_samp.`Sample_ID`
LEFT JOIN `Collected_Dimension` d_coll ON f.`Collected` = d_coll.`Date`
LEFT JOIN `Time_Dimension` d_time ON f.`Time` = d_time.`Time`
LEFT JOIN `Reported_Time_Dimension` d_rep ON f.`Reported Time` = d_rep.`Reported_Time`;


-- --------------------------------------------------------------------------
-- 2.9 Fact_Urine_ACR
-- --------------------------------------------------------------------------
DROP TABLE IF EXISTS `Fact_Urine_ACR`;
CREATE TABLE `Fact_Urine_ACR` (
  `MedID_FK` BIGINT NOT NULL, `LabReference_FK` BIGINT NOT NULL,
  `SampleID_FK` BIGINT NOT NULL, `Collected_FK` BIGINT NOT NULL,
  `Time_FK` BIGINT NOT NULL, `Reported_Time_FK` BIGINT NOT NULL,
  `Urine_Albumin` DOUBLE NOT NULL, `Urine_Creatinine` DOUBLE NOT NULL,
  `Albumin_Creatinine_Ratio` DOUBLE NOT NULL
) ENGINE=InnoDB;

INSERT INTO `Fact_Urine_ACR`
SELECT
  COALESCE(d_med.ID, -1), COALESCE(d_lab.ID, -1), COALESCE(d_samp.ID, -1),
  COALESCE(d_coll.ID, -1), COALESCE(d_time.ID, -1), COALESCE(d_rep.ID, -1),
  COALESCE(f.`Urine Albumin _mg_L_`, 0.0),
  COALESCE(f.`Urine Creatinine _mg_dL_`, 0.0),
  COALESCE(f.`Albumin_Creatinine Ratio`, 0.0)
FROM `Medical_Records_Cleaned` f
LEFT JOIN `MedID_Dimension` d_med ON CAST(f.`MedID` AS CHAR) = d_med.`Original_MedID`
LEFT JOIN `LabReference_Dimension` d_lab ON f.`LabReference` = d_lab.`LabReference`
LEFT JOIN `SampleID_Dimension` d_samp ON CAST(f.`Sample ID` AS CHAR) = d_samp.`Sample_ID`
LEFT JOIN `Collected_Dimension` d_coll ON f.`Collected` = d_coll.`Date`
LEFT JOIN `Time_Dimension` d_time ON f.`Time` = d_time.`Time`
LEFT JOIN `Reported_Time_Dimension` d_rep ON f.`Reported Time` = d_rep.`Reported_Time`;


-- --------------------------------------------------------------------------
-- 2.10 Fact_Calcium_Phos
-- --------------------------------------------------------------------------
DROP TABLE IF EXISTS `Fact_Calcium_Phos`;
CREATE TABLE `Fact_Calcium_Phos` (
  `MedID_FK` BIGINT NOT NULL, `LabReference_FK` BIGINT NOT NULL,
  `SampleID_FK` BIGINT NOT NULL, `Collected_FK` BIGINT NOT NULL,
  `Time_FK` BIGINT NOT NULL, `Reported_Time_FK` BIGINT NOT NULL,
  `Calcium` DOUBLE NOT NULL, `Phosphorus` DOUBLE NOT NULL
) ENGINE=InnoDB;

INSERT INTO `Fact_Calcium_Phos`
SELECT
  COALESCE(d_med.ID, -1), COALESCE(d_lab.ID, -1), COALESCE(d_samp.ID, -1),
  COALESCE(d_coll.ID, -1), COALESCE(d_time.ID, -1), COALESCE(d_rep.ID, -1),
  COALESCE(f.`Calcium _mg_dL_`, 0.0),
  COALESCE(f.`Phosphorus _mg_dL_`, 0.0)
FROM `Medical_Records_Cleaned` f
LEFT JOIN `MedID_Dimension` d_med ON CAST(f.`MedID` AS CHAR) = d_med.`Original_MedID`
LEFT JOIN `LabReference_Dimension` d_lab ON f.`LabReference` = d_lab.`LabReference`
LEFT JOIN `SampleID_Dimension` d_samp ON CAST(f.`Sample ID` AS CHAR) = d_samp.`Sample_ID`
LEFT JOIN `Collected_Dimension` d_coll ON f.`Collected` = d_coll.`Date`
LEFT JOIN `Time_Dimension` d_time ON f.`Time` = d_time.`Time`
LEFT JOIN `Reported_Time_Dimension` d_rep ON f.`Reported Time` = d_rep.`Reported_Time`;


-- --------------------------------------------------------------------------
-- 2.11 Fact_Thyroid_Profile
-- --------------------------------------------------------------------------
DROP TABLE IF EXISTS `Fact_Thyroid_Profile`;
CREATE TABLE `Fact_Thyroid_Profile` (
  `MedID_FK` BIGINT NOT NULL, `LabReference_FK` BIGINT NOT NULL,
  `SampleID_FK` BIGINT NOT NULL, `Collected_FK` BIGINT NOT NULL,
  `Time_FK` BIGINT NOT NULL, `Reported_Time_FK` BIGINT NOT NULL,
  `TT3` BIGINT NOT NULL, `TT4` DOUBLE NOT NULL, `TSH` DOUBLE NOT NULL
) ENGINE=InnoDB;

INSERT INTO `Fact_Thyroid_Profile`
SELECT
  COALESCE(d_med.ID, -1), COALESCE(d_lab.ID, -1), COALESCE(d_samp.ID, -1),
  COALESCE(d_coll.ID, -1), COALESCE(d_time.ID, -1), COALESCE(d_rep.ID, -1),
  COALESCE(f.`TT3 _ng_dL_`, 0),
  COALESCE(f.`TT4 _µg_dL_`, 0.0),
  COALESCE(f.`TSH _µIU_mL_`, 0.0)
FROM `Medical_Records_Cleaned` f
LEFT JOIN `MedID_Dimension` d_med ON CAST(f.`MedID` AS CHAR) = d_med.`Original_MedID`
LEFT JOIN `LabReference_Dimension` d_lab ON f.`LabReference` = d_lab.`LabReference`
LEFT JOIN `SampleID_Dimension` d_samp ON CAST(f.`Sample ID` AS CHAR) = d_samp.`Sample_ID`
LEFT JOIN `Collected_Dimension` d_coll ON f.`Collected` = d_coll.`Date`
LEFT JOIN `Time_Dimension` d_time ON f.`Time` = d_time.`Time`
LEFT JOIN `Reported_Time_Dimension` d_rep ON f.`Reported Time` = d_rep.`Reported_Time`;


-- --------------------------------------------------------------------------
-- 2.12 Fact_Glucose_Fasting
-- --------------------------------------------------------------------------
DROP TABLE IF EXISTS `Fact_Glucose_Fasting`;
CREATE TABLE `Fact_Glucose_Fasting` (
  `MedID_FK` BIGINT NOT NULL, `LabReference_FK` BIGINT NOT NULL,
  `SampleID_FK` BIGINT NOT NULL, `Collected_FK` BIGINT NOT NULL,
  `Time_FK` BIGINT NOT NULL, `Reported_Time_FK` BIGINT NOT NULL,
  `Fasting_Glucose` BIGINT NOT NULL
) ENGINE=InnoDB;

INSERT INTO `Fact_Glucose_Fasting`
SELECT
  COALESCE(d_med.ID, -1), COALESCE(d_lab.ID, -1), COALESCE(d_samp.ID, -1),
  COALESCE(d_coll.ID, -1), COALESCE(d_time.ID, -1), COALESCE(d_rep.ID, -1),
  COALESCE(f.`Fasting Glucose _mg_dL_`, 0)
FROM `Medical_Records_Cleaned` f
LEFT JOIN `MedID_Dimension` d_med ON CAST(f.`MedID` AS CHAR) = d_med.`Original_MedID`
LEFT JOIN `LabReference_Dimension` d_lab ON f.`LabReference` = d_lab.`LabReference`
LEFT JOIN `SampleID_Dimension` d_samp ON CAST(f.`Sample ID` AS CHAR) = d_samp.`Sample_ID`
LEFT JOIN `Collected_Dimension` d_coll ON f.`Collected` = d_coll.`Date`
LEFT JOIN `Time_Dimension` d_time ON f.`Time` = d_time.`Time`
LEFT JOIN `Reported_Time_Dimension` d_rep ON f.`Reported Time` = d_rep.`Reported_Time`;


-- --------------------------------------------------------------------------
-- 2.13 Fact_Glucose_PP
-- --------------------------------------------------------------------------
DROP TABLE IF EXISTS `Fact_Glucose_PP`;
CREATE TABLE `Fact_Glucose_PP` (
  `MedID_FK` BIGINT NOT NULL, `LabReference_FK` BIGINT NOT NULL,
  `SampleID_FK` BIGINT NOT NULL, `Collected_FK` BIGINT NOT NULL,
  `Time_FK` BIGINT NOT NULL, `Reported_Time_FK` BIGINT NOT NULL,
  `Postprandial_Glucose` BIGINT NOT NULL
) ENGINE=InnoDB;

INSERT INTO `Fact_Glucose_PP`
SELECT
  COALESCE(d_med.ID, -1), COALESCE(d_lab.ID, -1), COALESCE(d_samp.ID, -1),
  COALESCE(d_coll.ID, -1), COALESCE(d_time.ID, -1), COALESCE(d_rep.ID, -1),
  COALESCE(f.`Postprandial Glucose _mg_dL_`, 0)
FROM `Medical_Records_Cleaned` f
LEFT JOIN `MedID_Dimension` d_med ON CAST(f.`MedID` AS CHAR) = d_med.`Original_MedID`
LEFT JOIN `LabReference_Dimension` d_lab ON f.`LabReference` = d_lab.`LabReference`
LEFT JOIN `SampleID_Dimension` d_samp ON CAST(f.`Sample ID` AS CHAR) = d_samp.`Sample_ID`
LEFT JOIN `Collected_Dimension` d_coll ON f.`Collected` = d_coll.`Date`
LEFT JOIN `Time_Dimension` d_time ON f.`Time` = d_time.`Time`
LEFT JOIN `Reported_Time_Dimension` d_rep ON f.`Reported Time` = d_rep.`Reported_Time`;


-- --------------------------------------------------------------------------
-- 2.14 Fact_Glucose_Diagnopath
-- --------------------------------------------------------------------------
DROP TABLE IF EXISTS `Fact_Glucose_Diagnopath`;
CREATE TABLE `Fact_Glucose_Diagnopath` (
  `MedID_FK` BIGINT NOT NULL, `LabReference_FK` BIGINT NOT NULL,
  `SampleID_FK` BIGINT NOT NULL, `Collected_FK` BIGINT NOT NULL,
  `Time_FK` BIGINT NOT NULL, `Reported_Time_FK` BIGINT NOT NULL,
  `FBS` BIGINT NOT NULL, `PLBS` BIGINT NOT NULL
) ENGINE=InnoDB;

INSERT INTO `Fact_Glucose_Diagnopath`
SELECT
  COALESCE(d_med.ID, -1), COALESCE(d_lab.ID, -1), COALESCE(d_samp.ID, -1),
  COALESCE(d_coll.ID, -1), COALESCE(d_time.ID, -1), COALESCE(d_rep.ID, -1),
  COALESCE(f.`FBS _mg_dL_`, 0),
  COALESCE(f.`PLBS _mg_dL_`, 0)
FROM `Medical_Records_Cleaned` f
LEFT JOIN `MedID_Dimension` d_med ON CAST(f.`MedID` AS CHAR) = d_med.`Original_MedID`
LEFT JOIN `LabReference_Dimension` d_lab ON f.`LabReference` = d_lab.`LabReference`
LEFT JOIN `SampleID_Dimension` d_samp ON CAST(f.`Sample ID` AS CHAR) = d_samp.`Sample_ID`
LEFT JOIN `Collected_Dimension` d_coll ON f.`Collected` = d_coll.`Date`
LEFT JOIN `Time_Dimension` d_time ON f.`Time` = d_time.`Time`
LEFT JOIN `Reported_Time_Dimension` d_rep ON f.`Reported Time` = d_rep.`Reported_Time`;


-- ############################################################################
-- SECTION 3: VIEWS (14)
-- Each view joins a Fact table with MedID_Dimension and Collected_Dimension
-- to produce flat, dashboard-ready output.
-- ############################################################################

-- --------------------------------------------------------------------------
-- 3.1 View_Fact_Urine
-- --------------------------------------------------------------------------
CREATE OR REPLACE VIEW `View_Fact_Urine` AS
SELECT 
    IFNULL(m.`Original_MedID`, 'Unknown') AS Original_MedID,
    IFNULL(m.`First_Name`, 'Unknown') AS First_Name,
    IFNULL(m.`Last_Name`, 'Unknown') AS Last_Name,
    IFNULL(m.`Gender`, 'Unknown') AS Gender,
    IFNULL(m.`Age_Category`, 'Unknown') AS Age_Category,
    c.`Date` AS Test_Date,
    u.`Urine_Colour`, u.`Appearance`,
    u.`Specific_Gravity`, u.`pH`,
    u.`Proteins`, u.`Glucose`, u.`Bilirubin`, u.`Ketones`,
    u.`Blood`, u.`Urobilinogen`, u.`Nitrites`,
    u.`WBC_Pus_Cells`, u.`RBC`, u.`Epithelial_Cells`,
    u.`Casts`, u.`Crystals`, u.`Others`
FROM `Fact_Urine` AS u
LEFT JOIN `MedID_Dimension` AS m ON u.`MedID_FK` = m.`ID`
LEFT JOIN `Collected_Dimension` AS c ON u.`Collected_FK` = c.`ID`;


-- --------------------------------------------------------------------------
-- 3.2 View_Fact_CBC
-- --------------------------------------------------------------------------
CREATE OR REPLACE VIEW `View_Fact_CBC` AS
SELECT 
    IFNULL(m.`Original_MedID`, 'Unknown') AS Original_MedID,
    IFNULL(m.`First_Name`, 'Unknown') AS First_Name,
    IFNULL(m.`Last_Name`, 'Unknown') AS Last_Name,
    IFNULL(m.`Gender`, 'Unknown') AS Gender,
    IFNULL(m.`Age_Category`, 'Unknown') AS Age_Category,
    c.`Date` AS Test_Date,
    f.`Hemoglobin`, f.`RBC_Count`, f.`Hematocrit`,
    f.`MCV`, f.`MCH`, f.`MCHC`, f.`RDW_CV`, f.`RDW_SD`,
    f.`WBC_Count`, f.`Neutrophils`, f.`Lymphocytes`,
    f.`Eosinophils`, f.`Monocytes`, f.`Basophils`,
    f.`Abs_Neutrophils`, f.`Abs_Lymphocytes`,
    f.`Abs_Monocytes`, f.`Abs_Eosinophils`, f.`Abs_Basophils`
FROM `Fact_CBC` AS f
LEFT JOIN `MedID_Dimension` AS m ON f.`MedID_FK` = m.`ID`
LEFT JOIN `Collected_Dimension` AS c ON f.`Collected_FK` = c.`ID`;


-- --------------------------------------------------------------------------
-- 3.3 View_Fact_Platelet_Profile
-- --------------------------------------------------------------------------
CREATE OR REPLACE VIEW `View_Fact_Platelet_Profile` AS
SELECT 
    IFNULL(m.`Original_MedID`, 'Unknown') AS Original_MedID,
    IFNULL(m.`First_Name`, 'Unknown') AS First_Name,
    IFNULL(m.`Last_Name`, 'Unknown') AS Last_Name,
    IFNULL(m.`Gender`, 'Unknown') AS Gender,
    IFNULL(m.`Age_Category`, 'Unknown') AS Age_Category,
    c.`Date` AS Test_Date,
    CAST(f.`Platelet_Count` AS SIGNED) AS Platelet_Count,
    CAST(f.`MPV` AS DOUBLE) AS MPV,
    CAST(f.`Platelet_RDW` AS DOUBLE) AS Platelet_RDW,
    CAST(f.`PCT` AS DOUBLE) AS PCT,
    CAST(f.`P_LCR` AS DOUBLE) AS P_LCR,
    CAST(f.`IMG` AS DOUBLE) AS IMG,
    CAST(f.`IMM` AS DOUBLE) AS IMM,
    CAST(f.`IML` AS DOUBLE) AS IML,
    CAST(f.`LIC` AS DOUBLE) AS LIC
FROM `Fact_Platelet_Profile` AS f
LEFT JOIN `MedID_Dimension` AS m ON f.`MedID_FK` = m.`ID`
LEFT JOIN `Collected_Dimension` AS c ON f.`Collected_FK` = c.`ID`;


-- --------------------------------------------------------------------------
-- 3.4 View_Fact_Lipid_Profile
-- --------------------------------------------------------------------------
CREATE OR REPLACE VIEW `View_Fact_Lipid_Profile` AS
SELECT 
    IFNULL(m.`Original_MedID`, 'Unknown') AS Original_MedID,
    IFNULL(m.`First_Name`, 'Unknown') AS First_Name,
    IFNULL(m.`Last_Name`, 'Unknown') AS Last_Name,
    IFNULL(m.`Gender`, 'Unknown') AS Gender,
    IFNULL(m.`Age_Category`, 'Unknown') AS Age_Category,
    c.`Date` AS Test_Date,
    CAST(l.`Total_Cholesterol` AS SIGNED) AS Total_Cholesterol,
    CAST(l.`HDL` AS SIGNED) AS HDL,
    CAST(l.`LDL` AS DOUBLE) AS LDL,
    CAST(l.`VLDL` AS DOUBLE) AS VLDL,
    CAST(l.`Triglycerides` AS DOUBLE) AS Triglycerides,
    CAST(l.`Non_HDL` AS SIGNED) AS Non_HDL,
    CAST(l.`Total_HDL_Ratio` AS DOUBLE) AS Total_HDL_Ratio,
    CAST(l.`LDL_HDL_Ratio` AS DOUBLE) AS LDL_HDL_Ratio,
    CAST(l.`HDL_LDL_Ratio` AS DOUBLE) AS HDL_LDL_Ratio
FROM `Fact_Lipid_Profile` AS l
LEFT JOIN `MedID_Dimension` AS m ON l.`MedID_FK` = m.`ID`
LEFT JOIN `Collected_Dimension` AS c ON l.`Collected_FK` = c.`ID`;


-- --------------------------------------------------------------------------
-- 3.5 View_Fact_Liver_Function
-- --------------------------------------------------------------------------
CREATE OR REPLACE VIEW `View_Fact_Liver_Function` AS
SELECT 
    IFNULL(m.`Original_MedID`, 'Unknown') AS Original_MedID,
    IFNULL(m.`First_Name`, 'Unknown') AS First_Name,
    IFNULL(m.`Last_Name`, 'Unknown') AS Last_Name,
    IFNULL(m.`Gender`, 'Unknown') AS Gender,
    IFNULL(m.`Age_Category`, 'Unknown') AS Age_Category,
    c.`Date` AS Test_Date,
    u.`ALP`, u.`ALT_SGPT`, u.`AST_SGOT`, u.`GGT`,
    u.`Bilirubin_Total`, u.`Bilirubin_Direct`, u.`Bilirubin_Indirect`,
    u.`Protein_Total`, u.`Albumin`, u.`Globulin`, u.`A_G_Ratio`
FROM `Fact_Liver_Function` AS u
LEFT JOIN `MedID_Dimension` AS m ON u.`MedID_FK` = m.`ID`
LEFT JOIN `Collected_Dimension` AS c ON u.`Collected_FK` = c.`ID`;


-- --------------------------------------------------------------------------
-- 3.6 View_Fact_Kidney_Function
-- --------------------------------------------------------------------------
CREATE OR REPLACE VIEW `View_Fact_Kidney_Function` AS
SELECT 
    IFNULL(m.`Original_MedID`, 'Unknown') AS Original_MedID,
    IFNULL(m.`First_Name`, 'Unknown') AS First_Name,
    IFNULL(m.`Last_Name`, 'Unknown') AS Last_Name,
    IFNULL(m.`Gender`, 'Unknown') AS Gender,
    IFNULL(m.`Age_Category`, 'Unknown') AS Age_Category,
    c.`Date` AS Test_Date,
    u.`Creatinine`, u.`Urea`, u.`BUN`, u.`BUN_Creatinine_Ratio`,
    u.`eGFR`, u.`Uric_Acid`,
    u.`Sodium`, u.`Potassium`, u.`Chloride`
FROM `Fact_Kidney_Function` AS u
LEFT JOIN `MedID_Dimension` AS m ON u.`MedID_FK` = m.`ID`
LEFT JOIN `Collected_Dimension` AS c ON u.`Collected_FK` = c.`ID`;


-- --------------------------------------------------------------------------
-- 3.7 View_Fact_Iron_Profile
-- --------------------------------------------------------------------------
CREATE OR REPLACE VIEW `View_Fact_Iron_Profile` AS
SELECT 
    IFNULL(m.`Original_MedID`, 'Unknown') AS Original_MedID,
    IFNULL(m.`First_Name`, 'Unknown') AS First_Name,
    IFNULL(m.`Last_Name`, 'Unknown') AS Last_Name,
    IFNULL(m.`Gender`, 'Unknown') AS Gender,
    IFNULL(m.`Age_Category`, 'Unknown') AS Age_Category,
    c.`Date` AS Test_Date,
    CAST(i.`Iron` AS DOUBLE) AS Iron,
    CAST(i.`UIBC` AS DOUBLE) AS UIBC,
    CAST(i.`TIBC` AS DOUBLE) AS TIBC,
    CAST(i.`Transferrin_Saturation` AS DOUBLE) AS Transferrin_Saturation
FROM `Fact_Iron_Profile` AS i
LEFT JOIN `MedID_Dimension` AS m ON i.`MedID_FK` = m.`ID`
LEFT JOIN `Collected_Dimension` AS c ON i.`Collected_FK` = c.`ID`;


-- --------------------------------------------------------------------------
-- 3.8 View_Fact_HbA1c
-- --------------------------------------------------------------------------
CREATE OR REPLACE VIEW `View_Fact_HbA1c` AS
SELECT 
    IFNULL(P.`Original_MedID`, 'Unknown') AS Original_MedID,
    IFNULL(P.`First_Name`, 'Unknown') AS First_Name,
    IFNULL(P.`Last_Name`, 'Unknown') AS Last_Name,
    IFNULL(P.`Gender`, 'Unknown') AS Gender,
    IFNULL(P.`Age_Category`, 'Unknown') AS Age_Category,
    IFNULL(D.`Date`, '1970-01-01') AS Test_Date,
    IFNULL(F.`HbA1c`, 0.0) AS HbA1c,
    IFNULL(F.`Estimated_Avg_Glucose`, 0.0) AS Estimated_Avg_Glucose,
    IFNULL(F.`HbF`, 0.0) AS HbF
FROM `Fact_HbA1c` F
JOIN `MedID_Dimension` P ON F.`MedID_FK` = P.`ID`
JOIN `Collected_Dimension` D ON F.`Collected_FK` = D.`ID`;


-- --------------------------------------------------------------------------
-- 3.9 View_Fact_Urine_ACR
-- --------------------------------------------------------------------------
CREATE OR REPLACE VIEW `View_Fact_Urine_ACR` AS
SELECT 
    IFNULL(P.`Original_MedID`, 'Unknown') AS Original_MedID,
    IFNULL(P.`First_Name`, 'Unknown') AS First_Name,
    IFNULL(P.`Last_Name`, 'Unknown') AS Last_Name,
    IFNULL(P.`Gender`, 'Unknown') AS Gender,
    IFNULL(P.`Age_Category`, 'Unknown') AS Age_Category,
    IFNULL(D.`Date`, '1970-01-01') AS Test_Date,
    IFNULL(F.`Urine_Albumin`, 0.0) AS Urine_Albumin,
    IFNULL(F.`Urine_Creatinine`, 0.0) AS Urine_Creatinine,
    IFNULL(F.`Albumin_Creatinine_Ratio`, 0.0) AS Albumin_Creatinine_Ratio
FROM `Fact_Urine_ACR` F
JOIN `MedID_Dimension` P ON F.`MedID_FK` = P.`ID`
JOIN `Collected_Dimension` D ON F.`Collected_FK` = D.`ID`;


-- --------------------------------------------------------------------------
-- 3.10 View_Fact_Calcium_Phos
-- --------------------------------------------------------------------------
CREATE OR REPLACE VIEW `View_Fact_Calcium_Phos` AS
SELECT 
    IFNULL(P.`Original_MedID`, 'Unknown') AS Original_MedID,
    IFNULL(P.`First_Name`, 'Unknown') AS First_Name,
    IFNULL(P.`Last_Name`, 'Unknown') AS Last_Name,
    IFNULL(P.`Gender`, 'Unknown') AS Gender,
    IFNULL(P.`Age_Category`, 'Unknown') AS Age_Category,
    IFNULL(D.`Date`, '1970-01-01') AS Test_Date,
    IFNULL(F.`Calcium`, 0.0) AS Calcium,
    IFNULL(F.`Phosphorus`, 0.0) AS Phosphorus
FROM `Fact_Calcium_Phos` F
JOIN `MedID_Dimension` P ON F.`MedID_FK` = P.`ID`
JOIN `Collected_Dimension` D ON F.`Collected_FK` = D.`ID`;


-- --------------------------------------------------------------------------
-- 3.11 View_Fact_Thyroid_Profile
-- --------------------------------------------------------------------------
CREATE OR REPLACE VIEW `View_Fact_Thyroid_Profile` AS
SELECT 
    IFNULL(P.`Original_MedID`, 'Unknown') AS Original_MedID,
    IFNULL(P.`First_Name`, 'Unknown') AS First_Name,
    IFNULL(P.`Last_Name`, 'Unknown') AS Last_Name,
    IFNULL(P.`Gender`, 'Unknown') AS Gender,
    IFNULL(P.`Age_Category`, 'Unknown') AS Age_Category,
    IFNULL(D.`Date`, '1970-01-01') AS Test_Date,
    IFNULL(F.`TT3`, 0) AS TT3,
    IFNULL(F.`TT4`, 0.0) AS TT4,
    IFNULL(F.`TSH`, 0.0) AS TSH
FROM `Fact_Thyroid_Profile` F
JOIN `MedID_Dimension` P ON F.`MedID_FK` = P.`ID`
JOIN `Collected_Dimension` D ON F.`Collected_FK` = D.`ID`;


-- --------------------------------------------------------------------------
-- 3.12 View_Fact_Glucose_Fasting
-- --------------------------------------------------------------------------
CREATE OR REPLACE VIEW `View_Fact_Glucose_Fasting` AS
SELECT 
    IFNULL(P.`Original_MedID`, 'Unknown') AS Original_MedID,
    IFNULL(P.`First_Name`, 'Unknown') AS First_Name,
    IFNULL(P.`Last_Name`, 'Unknown') AS Last_Name,
    IFNULL(P.`Gender`, 'Unknown') AS Gender,
    IFNULL(P.`Age_Category`, 'Unknown') AS Age_Category,
    IFNULL(D.`Date`, '1970-01-01') AS Test_Date,
    IFNULL(F.`Fasting_Glucose`, 0) AS Fasting_Glucose
FROM `Fact_Glucose_Fasting` F
JOIN `MedID_Dimension` P ON F.`MedID_FK` = P.`ID`
JOIN `Collected_Dimension` D ON F.`Collected_FK` = D.`ID`;


-- --------------------------------------------------------------------------
-- 3.13 View_Fact_Glucose_PP
-- --------------------------------------------------------------------------
CREATE OR REPLACE VIEW `View_Fact_Glucose_PP` AS
SELECT 
    IFNULL(P.`Original_MedID`, 'Unknown') AS Original_MedID,
    IFNULL(P.`First_Name`, 'Unknown') AS First_Name,
    IFNULL(P.`Last_Name`, 'Unknown') AS Last_Name,
    IFNULL(P.`Gender`, 'Unknown') AS Gender,
    IFNULL(P.`Age_Category`, 'Unknown') AS Age_Category,
    IFNULL(D.`Date`, '1970-01-01') AS Test_Date,
    IFNULL(F.`Postprandial_Glucose`, 0) AS Postprandial_Glucose
FROM `Fact_Glucose_PP` F
JOIN `MedID_Dimension` P ON F.`MedID_FK` = P.`ID`
JOIN `Collected_Dimension` D ON F.`Collected_FK` = D.`ID`;


-- --------------------------------------------------------------------------
-- 3.14 View_Fact_Glucose_Diagnopath
-- --------------------------------------------------------------------------
CREATE OR REPLACE VIEW `View_Fact_Glucose_Diagnopath` AS
SELECT 
    IFNULL(P.`Original_MedID`, 'Unknown') AS Original_MedID,
    IFNULL(P.`First_Name`, 'Unknown') AS First_Name,
    IFNULL(P.`Last_Name`, 'Unknown') AS Last_Name,
    IFNULL(P.`Gender`, 'Unknown') AS Gender,
    IFNULL(P.`Age_Category`, 'Unknown') AS Age_Category,
    IFNULL(D.`Date`, '1970-01-01') AS Test_Date,
    IFNULL(F.`FBS`, 0) AS FBS,
    IFNULL(F.`PLBS`, 0) AS PLBS
FROM `Fact_Glucose_Diagnopath` F
JOIN `MedID_Dimension` P ON F.`MedID_FK` = P.`ID`
JOIN `Collected_Dimension` D ON F.`Collected_FK` = D.`ID`;


-- ============================================================================
-- END OF SCRIPT
-- Total objects created:
--   4 Source Table Stubs
--   6 Dimension Tables (with INSERT INTO ... SELECT)
--  14 Fact Tables (with INSERT INTO ... SELECT)
--  14 Views
-- ============================================================================
