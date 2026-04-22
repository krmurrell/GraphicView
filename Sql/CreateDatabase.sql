-- ============================================================
-- GraphicView - Age/Sex Population Pyramid Database Setup
-- ============================================================
-- Run this script against a SQL Server instance (as a user
-- with permission to create databases and objects).
-- ============================================================

-- 1. Create (or switch to) the database
-- Uncomment the next two lines if you need to create the DB:
-- CREATE DATABASE GraphicViewDB;
-- GO

USE GraphicViewDB;
GO

-- 2. Drop table if it already exists (for re-runs)
IF OBJECT_ID(N'dbo.PopulationData', N'U') IS NOT NULL
    DROP TABLE dbo.PopulationData;
GO

-- 3. Create the PopulationData table
CREATE TABLE dbo.PopulationData
(
    Id         INT          IDENTITY(1,1) NOT NULL,
    AgeGroup   VARCHAR(10)  NOT NULL,          -- e.g. '0-4', '5-9', … '80+'
    Sex        CHAR(1)      NOT NULL,           -- 'M' = Male, 'F' = Female
    Population INT          NOT NULL DEFAULT 0,
    Year       INT          NOT NULL,
    Region     VARCHAR(100) NOT NULL DEFAULT 'National',
    CONSTRAINT PK_PopulationData  PRIMARY KEY CLUSTERED (Id ASC),
    CONSTRAINT CK_Sex             CHECK (Sex IN ('M','F')),
    CONSTRAINT CK_Population      CHECK (Population >= 0),
    CONSTRAINT CK_Year            CHECK (Year > 0)
);
GO

-- 4. Index to speed up filtered queries
CREATE NONCLUSTERED INDEX IX_PopulationData_Year_Region
    ON dbo.PopulationData (Year, Region);
GO

-- ============================================================
-- 5. Sample data
--    Two years (2020, 2023) × two regions (National, Urban)
-- ============================================================

-- ---- 2020 · National ----------------------------------------
INSERT INTO dbo.PopulationData (AgeGroup, Sex, Population, Year, Region) VALUES
('0-4',  'M',  9750, 2020, 'National'),
('0-4',  'F',  9320, 2020, 'National'),
('5-9',  'M', 10230, 2020, 'National'),
('5-9',  'F',  9870, 2020, 'National'),
('10-14','M', 10540, 2020, 'National'),
('10-14','F', 10020, 2020, 'National'),
('15-19','M', 11080, 2020, 'National'),
('15-19','F', 10760, 2020, 'National'),
('20-24','M', 11560, 2020, 'National'),
('20-24','F', 11430, 2020, 'National'),
('25-29','M', 12100, 2020, 'National'),
('25-29','F', 12340, 2020, 'National'),
('30-34','M', 11870, 2020, 'National'),
('30-34','F', 12150, 2020, 'National'),
('35-39','M', 11230, 2020, 'National'),
('35-39','F', 11560, 2020, 'National'),
('40-44','M', 10890, 2020, 'National'),
('40-44','F', 11230, 2020, 'National'),
('45-49','M', 10340, 2020, 'National'),
('45-49','F', 10780, 2020, 'National'),
('50-54','M',  9760, 2020, 'National'),
('50-54','F', 10230, 2020, 'National'),
('55-59','M',  8940, 2020, 'National'),
('55-59','F',  9560, 2020, 'National'),
('60-64','M',  7820, 2020, 'National'),
('60-64','F',  8490, 2020, 'National'),
('65-69','M',  6540, 2020, 'National'),
('65-69','F',  7230, 2020, 'National'),
('70-74','M',  5230, 2020, 'National'),
('70-74','F',  6080, 2020, 'National'),
('75-79','M',  3780, 2020, 'National'),
('75-79','F',  4650, 2020, 'National'),
('80+',  'M',  2960, 2020, 'National'),
('80+',  'F',  4120, 2020, 'National');

-- ---- 2020 · Urban -------------------------------------------
INSERT INTO dbo.PopulationData (AgeGroup, Sex, Population, Year, Region) VALUES
('0-4',  'M',  4870, 2020, 'Urban'),
('0-4',  'F',  4650, 2020, 'Urban'),
('5-9',  'M',  5110, 2020, 'Urban'),
('5-9',  'F',  4930, 2020, 'Urban'),
('10-14','M',  5260, 2020, 'Urban'),
('10-14','F',  5010, 2020, 'Urban'),
('15-19','M',  5530, 2020, 'Urban'),
('15-19','F',  5380, 2020, 'Urban'),
('20-24','M',  5780, 2020, 'Urban'),
('20-24','F',  5720, 2020, 'Urban'),
('25-29','M',  6050, 2020, 'Urban'),
('25-29','F',  6170, 2020, 'Urban'),
('30-34','M',  5930, 2020, 'Urban'),
('30-34','F',  6080, 2020, 'Urban'),
('35-39','M',  5610, 2020, 'Urban'),
('35-39','F',  5780, 2020, 'Urban'),
('40-44','M',  5450, 2020, 'Urban'),
('40-44','F',  5620, 2020, 'Urban'),
('45-49','M',  5170, 2020, 'Urban'),
('45-49','F',  5390, 2020, 'Urban'),
('50-54','M',  4880, 2020, 'Urban'),
('50-54','F',  5120, 2020, 'Urban'),
('55-59','M',  4470, 2020, 'Urban'),
('55-59','F',  4780, 2020, 'Urban'),
('60-64','M',  3910, 2020, 'Urban'),
('60-64','F',  4250, 2020, 'Urban'),
('65-69','M',  3270, 2020, 'Urban'),
('65-69','F',  3620, 2020, 'Urban'),
('70-74','M',  2620, 2020, 'Urban'),
('70-74','F',  3040, 2020, 'Urban'),
('75-79','M',  1890, 2020, 'Urban'),
('75-79','F',  2330, 2020, 'Urban'),
('80+',  'M',  1480, 2020, 'Urban'),
('80+',  'F',  2060, 2020, 'Urban');

-- ---- 2023 · National ----------------------------------------
INSERT INTO dbo.PopulationData (AgeGroup, Sex, Population, Year, Region) VALUES
('0-4',  'M',  9560, 2023, 'National'),
('0-4',  'F',  9140, 2023, 'National'),
('5-9',  'M', 10110, 2023, 'National'),
('5-9',  'F',  9710, 2023, 'National'),
('10-14','M', 10400, 2023, 'National'),
('10-14','F',  9900, 2023, 'National'),
('15-19','M', 10900, 2023, 'National'),
('15-19','F', 10600, 2023, 'National'),
('20-24','M', 11380, 2023, 'National'),
('20-24','F', 11260, 2023, 'National'),
('25-29','M', 11930, 2023, 'National'),
('25-29','F', 12180, 2023, 'National'),
('30-34','M', 11700, 2023, 'National'),
('30-34','F', 12000, 2023, 'National'),
('35-39','M', 11070, 2023, 'National'),
('35-39','F', 11410, 2023, 'National'),
('40-44','M', 10750, 2023, 'National'),
('40-44','F', 11090, 2023, 'National'),
('45-49','M', 10220, 2023, 'National'),
('45-49','F', 10660, 2023, 'National'),
('50-54','M',  9670, 2023, 'National'),
('50-54','F', 10140, 2023, 'National'),
('55-59','M',  8870, 2023, 'National'),
('55-59','F',  9500, 2023, 'National'),
('60-64','M',  7760, 2023, 'National'),
('60-64','F',  8440, 2023, 'National'),
('65-69','M',  6510, 2023, 'National'),
('65-69','F',  7210, 2023, 'National'),
('70-74','M',  5290, 2023, 'National'),
('70-74','F',  6150, 2023, 'National'),
('75-79','M',  3860, 2023, 'National'),
('75-79','F',  4740, 2023, 'National'),
('80+',  'M',  3120, 2023, 'National'),
('80+',  'F',  4380, 2023, 'National');

-- ---- 2023 · Urban -------------------------------------------
INSERT INTO dbo.PopulationData (AgeGroup, Sex, Population, Year, Region) VALUES
('0-4',  'M',  4780, 2023, 'Urban'),
('0-4',  'F',  4570, 2023, 'Urban'),
('5-9',  'M',  5050, 2023, 'Urban'),
('5-9',  'F',  4850, 2023, 'Urban'),
('10-14','M',  5200, 2023, 'Urban'),
('10-14','F',  4950, 2023, 'Urban'),
('15-19','M',  5450, 2023, 'Urban'),
('15-19','F',  5300, 2023, 'Urban'),
('20-24','M',  5690, 2023, 'Urban'),
('20-24','F',  5630, 2023, 'Urban'),
('25-29','M',  5965, 2023, 'Urban'),
('25-29','F',  6090, 2023, 'Urban'),
('30-34','M',  5850, 2023, 'Urban'),
('30-34','F',  6000, 2023, 'Urban'),
('35-39','M',  5535, 2023, 'Urban'),
('35-39','F',  5705, 2023, 'Urban'),
('40-44','M',  5375, 2023, 'Urban'),
('40-44','F',  5545, 2023, 'Urban'),
('45-49','M',  5110, 2023, 'Urban'),
('45-49','F',  5330, 2023, 'Urban'),
('50-54','M',  4835, 2023, 'Urban'),
('50-54','F',  5070, 2023, 'Urban'),
('55-59','M',  4435, 2023, 'Urban'),
('55-59','F',  4750, 2023, 'Urban'),
('60-64','M',  3880, 2023, 'Urban'),
('60-64','F',  4220, 2023, 'Urban'),
('65-69','M',  3255, 2023, 'Urban'),
('65-69','F',  3605, 2023, 'Urban'),
('70-74','M',  2645, 2023, 'Urban'),
('70-74','F',  3075, 2023, 'Urban'),
('75-79','M',  1930, 2023, 'Urban'),
('75-79','F',  2370, 2023, 'Urban'),
('80+',  'M',  1560, 2023, 'Urban'),
('80+',  'F',  2190, 2023, 'Urban');

GO

-- ============================================================
-- 6. Verify
-- ============================================================
SELECT Region, Year, COUNT(*) AS Rows,
       SUM(CASE WHEN Sex = 'M' THEN Population ELSE 0 END) AS TotalMale,
       SUM(CASE WHEN Sex = 'F' THEN Population ELSE 0 END) AS TotalFemale
FROM dbo.PopulationData
GROUP BY Region, Year
ORDER BY Region, Year;
GO
