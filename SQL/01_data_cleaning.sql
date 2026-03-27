/* =========================================================
   Project: Six Nations Rugby Performance Analysis (SQL & Power BI)
   File: 01_data_cleaning.sql
   Author: Kye Jones

   Purpose:
   Prepare raw rugby datasets for analysis by:
   - Creating working copies of imported tables
   - Checking for missing values and data quality
   - Verifying team name consistency
   - Adding calculated fields (Winner, PointDiff)
   - Preserving original raw data

   Tables used: six_nations (raw), internationals (raw)
   Tables created: six_nations_clean, internationals_clean
   ========================================================= */


/* ---------------------------------------------------------
   STEP 1: Create clean working tables from raw imports
   Note: Run these once to create the clean copies.
   They are commented out after first execution.
   --------------------------------------------------------- */

-- CREATE TABLE internationals_clean AS
-- SELECT * FROM internationals;

-- CREATE TABLE six_nations_clean AS
-- SELECT * FROM six_nations;


/* ---------------------------------------------------------
   STEP 2: Data quality checks — missing values
   Business reason: Missing scores or team names would
   corrupt aggregation results and win/loss calculations.
   --------------------------------------------------------- */

-- Check for missing scores in internationals data
SELECT * FROM internationals_clean
WHERE home_score IS NULL OR away_score IS NULL;

-- Check for missing scores in Six Nations data
SELECT * FROM six_nations_clean
WHERE HomeScore IS NULL OR AwayScore IS NULL;

-- Check for missing team names in internationals data
SELECT * FROM internationals_clean
WHERE home_team IS NULL OR away_team IS NULL;

-- Check for missing team names in Six Nations data
SELECT * FROM six_nations_clean
WHERE HomeTeam IS NULL OR AwayTeam IS NULL;


/* ---------------------------------------------------------
   STEP 3: Team name consistency check
   Business reason: If "England" appears as "ENG" in some rows,
   GROUP BY would treat them as separate teams.
   --------------------------------------------------------- */

SELECT HomeTeam, COUNT(*) AS games FROM six_nations_clean
GROUP BY HomeTeam ORDER BY games DESC;

SELECT AwayTeam, COUNT(*) AS games FROM six_nations_clean
GROUP BY AwayTeam ORDER BY games DESC;

SELECT home_team, COUNT(*) AS games FROM internationals_clean
GROUP BY home_team ORDER BY games DESC;


/* ---------------------------------------------------------
   STEP 4: Add calculated fields for analysis
   - Winner: identifies the winning team per match
   - PointDiff: absolute score margin
   --------------------------------------------------------- */

-- ALTER TABLE six_nations_clean ADD COLUMN Winner TEXT;
-- ALTER TABLE six_nations_clean ADD COLUMN PointDiff INTEGER;

UPDATE six_nations_clean
SET Winner = CASE
    WHEN HomeScore > AwayScore THEN HomeTeam
    WHEN AwayScore > HomeScore THEN AwayTeam
    ELSE 'Draw'
END;

UPDATE six_nations_clean
SET PointDiff = ABS(HomeScore - AwayScore);


/* ---------------------------------------------------------
   STEP 5: Validation — confirm calculated fields
   --------------------------------------------------------- */

SELECT Year, Date, HomeTeam, AwayTeam, HomeScore, AwayScore, Winner, PointDiff
FROM six_nations_clean
LIMIT 15;
