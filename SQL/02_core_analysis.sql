/* =========================================================
   Project: Six Nations Rugby Performance Analysis (SQL & Power BI)
   File: 02_core_analysis.sql
   Author: Kye Jones

   Purpose:
   Core analytical queries answering fundamental performance questions.
   
   Skills demonstrated:
   SELECT, WHERE, GROUP BY, ORDER BY, HAVING, COUNT, SUM, AVG,
   ROUND, CASE WHEN, UNION ALL, subqueries, calculated columns
   ========================================================= */


/* ---------------------------------------------------------
   ANALYSIS 1: Total wins by team
   Which teams have been the most successful?
   --------------------------------------------------------- */

SELECT Winner, COUNT(*) AS Wins
FROM six_nations_clean
WHERE Winner != 'Draw'
GROUP BY Winner
ORDER BY Wins DESC;


/* ---------------------------------------------------------
   ANALYSIS 2: Average points scored by team
   Which teams have been the strongest attacking sides?
   --------------------------------------------------------- */

SELECT Team, ROUND(AVG(Points), 2) AS AvgPoints
FROM (
    SELECT HomeTeam AS Team, HomeScore AS Points FROM six_nations_clean
    UNION ALL
    SELECT AwayTeam AS Team, AwayScore AS Points FROM six_nations_clean
)
GROUP BY Team
ORDER BY AvgPoints DESC;


/* ---------------------------------------------------------
   ANALYSIS 3: Team win rate
   Which teams have been the most consistently successful?
   --------------------------------------------------------- */

SELECT
    team,
    COUNT(*) AS matches_played,
    SUM(win) AS wins,
    ROUND(1.0 * SUM(win) / COUNT(*), 3) AS win_rate
FROM (
    SELECT HomeTeam AS team, CASE WHEN HomeScore > AwayScore THEN 1 ELSE 0 END AS win FROM six_nations_clean
    UNION ALL
    SELECT AwayTeam AS team, CASE WHEN AwayScore > HomeScore THEN 1 ELSE 0 END AS win FROM six_nations_clean
)
GROUP BY team
ORDER BY win_rate DESC;


/* ---------------------------------------------------------
   ANALYSIS 4: Home advantage
   How often does the home team win?
   --------------------------------------------------------- */

SELECT
    COUNT(*) AS total_matches,
    SUM(CASE WHEN HomeScore > AwayScore THEN 1 ELSE 0 END) AS home_wins,
    ROUND(1.0 * SUM(CASE WHEN HomeScore > AwayScore THEN 1 ELSE 0 END) / COUNT(*), 3) AS home_win_rate
FROM six_nations_clean;


/* ---------------------------------------------------------
   ANALYSIS 5: Closest matches (most competitive)
   --------------------------------------------------------- */

SELECT Year, Date, HomeTeam, AwayTeam, HomeScore, AwayScore, PointDiff
FROM six_nations_clean
ORDER BY PointDiff ASC, Date ASC
LIMIT 10;


/* ---------------------------------------------------------
   ANALYSIS 6: Largest winning margins
   --------------------------------------------------------- */

SELECT Year, Date, HomeTeam, AwayTeam, HomeScore, AwayScore, PointDiff
FROM six_nations_clean
ORDER BY PointDiff DESC, Date ASC
LIMIT 10;


/* ---------------------------------------------------------
   ANALYSIS 7: Average total points by year
   Has scoring changed over time?
   --------------------------------------------------------- */

SELECT Year, ROUND(AVG(HomeScore + AwayScore), 2) AS AvgTotalPoints
FROM six_nations_clean
GROUP BY Year
ORDER BY Year;


/* ---------------------------------------------------------
   ANALYSIS 8: Average margin of victory by year
   Has the tournament become more or less competitive?
   --------------------------------------------------------- */

SELECT Year, ROUND(AVG(PointDiff), 2) AS AvgMargin
FROM six_nations_clean
GROUP BY Year
ORDER BY Year;


/* ---------------------------------------------------------
   ANALYSIS 9: Team scoring by home vs away
   Do teams perform differently depending on venue?
   --------------------------------------------------------- */

SELECT Team, Venue, ROUND(AVG(Points), 2) AS AvgPoints
FROM (
    SELECT HomeTeam AS Team, 'Home' AS Venue, HomeScore AS Points FROM six_nations_clean
    UNION ALL
    SELECT AwayTeam AS Team, 'Away' AS Venue, AwayScore AS Points FROM six_nations_clean
)
GROUP BY Team, Venue
ORDER BY Team, Venue;


/* ---------------------------------------------------------
   ANALYSIS 10: Draw frequency
   How common are drawn matches?
   --------------------------------------------------------- */

SELECT
    COUNT(*) AS total_matches,
    SUM(CASE WHEN Winner = 'Draw' THEN 1 ELSE 0 END) AS draws,
    ROUND(1.0 * SUM(CASE WHEN Winner = 'Draw' THEN 1 ELSE 0 END) / COUNT(*), 3) AS draw_rate
FROM six_nations_clean;
