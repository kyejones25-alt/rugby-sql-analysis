/* =========================================================
   Project: Six Nations Rugby Performance Analysis (SQL & Power BI)
   File: 03_advanced_analysis.sql
   Author: Kye Jones

   Purpose:
   Advanced analytical queries using JOINs, CTEs, and window
   functions to answer deeper strategic questions.

   Skills demonstrated:
   INNER JOIN, Common Table Expressions (WITH), Window Functions
   (RANK, LAG, ROW_NUMBER, SUM OVER), PARTITION BY, subqueries
   ========================================================= */


/* ---------------------------------------------------------
   ANALYSIS 11: Six Nations win % vs overall international win %
   Do teams perform differently in the Six Nations vs all tests?

   Technique: Two CTEs joined together
   A CTE (Common Table Expression) is a temporary named result
   set defined with WITH...AS. Think of it as a mini-table that
   only exists for the duration of the query.
   --------------------------------------------------------- */

WITH six_nations_stats AS (
    SELECT 
        team,
        COUNT(*) AS sn_matches,
        ROUND(100.0 * SUM(CASE WHEN result = 'Win' THEN 1 ELSE 0 END) / COUNT(*), 1) AS sn_win_pct
    FROM (
        SELECT HomeTeam AS team, CASE WHEN HomeScore > AwayScore THEN 'Win' ELSE 'Other' END AS result FROM six_nations_clean
        UNION ALL
        SELECT AwayTeam AS team, CASE WHEN AwayScore > HomeScore THEN 'Win' ELSE 'Other' END AS result FROM six_nations_clean
    )
    GROUP BY team
),

international_stats AS (
    SELECT 
        team,
        COUNT(*) AS intl_matches,
        ROUND(100.0 * SUM(CASE WHEN result = 'Win' THEN 1 ELSE 0 END) / COUNT(*), 1) AS intl_win_pct
    FROM (
        SELECT home_team AS team, CASE WHEN home_score > away_score THEN 'Win' ELSE 'Other' END AS result FROM internationals_clean
        UNION ALL
        SELECT away_team AS team, CASE WHEN away_score > home_score THEN 'Win' ELSE 'Other' END AS result FROM internationals_clean
    )
    WHERE team IN ('England', 'France', 'Ireland', 'Italy', 'Scotland', 'Wales')
    GROUP BY team
)

SELECT 
    s.team,
    s.sn_matches,
    s.sn_win_pct,
    i.intl_matches,
    i.intl_win_pct,
    ROUND(s.sn_win_pct - i.intl_win_pct, 1) AS six_nations_vs_overall_diff
FROM six_nations_stats s
INNER JOIN international_stats i ON s.team = i.team
ORDER BY six_nations_vs_overall_diff DESC;


/* ---------------------------------------------------------
   ANALYSIS 12: Head-to-head records between all Six Nations teams
   Classic rivalry analysis — who dominates who?
   --------------------------------------------------------- */

SELECT
    HomeTeam,
    AwayTeam,
    COUNT(*) AS matches_played,
    SUM(CASE WHEN HomeScore > AwayScore THEN 1 ELSE 0 END) AS home_wins,
    SUM(CASE WHEN AwayScore > HomeScore THEN 1 ELSE 0 END) AS away_wins,
    SUM(CASE WHEN HomeScore = AwayScore THEN 1 ELSE 0 END) AS draws,
    ROUND(AVG(HomeScore + AwayScore), 1) AS avg_total_points
FROM six_nations_clean
GROUP BY HomeTeam, AwayTeam
ORDER BY HomeTeam, AwayTeam;


/* ---------------------------------------------------------
   ANALYSIS 13: Rank teams within each tournament year
   Who "won" each year?

   Technique: RANK() window function
   PARTITION BY Year = ranking resets each year
   ORDER BY wins DESC = best team gets rank 1
   --------------------------------------------------------- */

SELECT 
    team, Year, wins, point_differential,
    RANK() OVER (PARTITION BY Year ORDER BY wins DESC, point_differential DESC) AS tournament_rank
FROM (
    SELECT 
        team, Year,
        SUM(CASE WHEN result = 'Win' THEN 1 ELSE 0 END) AS wins,
        SUM(points_scored) - SUM(points_conceded) AS point_differential
    FROM (
        SELECT Year, HomeTeam AS team, HomeScore AS points_scored, AwayScore AS points_conceded,
               CASE WHEN HomeScore > AwayScore THEN 'Win' ELSE 'Other' END AS result
        FROM six_nations_clean
        UNION ALL
        SELECT Year, AwayTeam AS team, AwayScore AS points_scored, HomeScore AS points_conceded,
               CASE WHEN AwayScore > HomeScore THEN 'Win' ELSE 'Other' END AS result
        FROM six_nations_clean
    )
    GROUP BY team, Year
)
ORDER BY Year DESC, tournament_rank;


/* ---------------------------------------------------------
   ANALYSIS 14: Year-over-year point differential change
   Which teams are improving vs declining?

   Technique: LAG() window function
   LAG(column, 1) gets the PREVIOUS row's value for the same
   team. Subtract to get year-over-year change.
   Positive = improving. Negative = declining.
   --------------------------------------------------------- */

SELECT 
    team, Year, total_diff,
    LAG(total_diff, 1) OVER (PARTITION BY team ORDER BY Year) AS prev_year_diff,
    total_diff - LAG(total_diff, 1) OVER (PARTITION BY team ORDER BY Year) AS yoy_change
FROM (
    SELECT 
        team, Year,
        SUM(points_scored) - SUM(points_conceded) AS total_diff
    FROM (
        SELECT Year, HomeTeam AS team, HomeScore AS points_scored, AwayScore AS points_conceded FROM six_nations_clean
        UNION ALL
        SELECT Year, AwayTeam AS team, AwayScore AS points_scored, HomeScore AS points_conceded FROM six_nations_clean
    )
    GROUP BY team, Year
)
ORDER BY team, Year;


/* ---------------------------------------------------------
   ANALYSIS 15: Running cumulative wins per team
   Visualizes long-term dominance over time.

   Technique: SUM() OVER with ROWS UNBOUNDED PRECEDING
   Creates a running total from first match to current row.
   --------------------------------------------------------- */

SELECT 
    team, Date, result,
    SUM(CASE WHEN result = 'Win' THEN 1 ELSE 0 END) 
        OVER (PARTITION BY team ORDER BY Date ROWS UNBOUNDED PRECEDING) AS cumulative_wins
FROM (
    SELECT Date, HomeTeam AS team, CASE WHEN HomeScore > AwayScore THEN 'Win' ELSE 'Other' END AS result FROM six_nations_clean
    UNION ALL
    SELECT Date, AwayTeam AS team, CASE WHEN AwayScore > HomeScore THEN 'Win' ELSE 'Other' END AS result FROM six_nations_clean
)
ORDER BY team, Date;


/* ---------------------------------------------------------
   ANALYSIS 16: Longest consecutive win streaks per team
   Momentum analysis — which teams went on the biggest runs?

   Technique: Advanced streak detection using ROW_NUMBER gaps
   When a team's result changes (Win → Loss), the gap between
   two ROW_NUMBER sequences changes, creating unique "streak
   groups" for each consecutive run.
   --------------------------------------------------------- */

WITH match_results AS (
    SELECT 
        team, Date,
        CASE WHEN result = 'Win' THEN 1 ELSE 0 END AS is_win,
        ROW_NUMBER() OVER (PARTITION BY team ORDER BY Date) AS match_num
    FROM (
        SELECT Date, HomeTeam AS team, CASE WHEN HomeScore > AwayScore THEN 'Win' ELSE 'Other' END AS result FROM six_nations_clean
        UNION ALL
        SELECT Date, AwayTeam AS team, CASE WHEN AwayScore > HomeScore THEN 'Win' ELSE 'Other' END AS result FROM six_nations_clean
    )
),

streaks AS (
    SELECT team, Date, is_win, match_num,
        match_num - ROW_NUMBER() OVER (PARTITION BY team, is_win ORDER BY Date) AS streak_group
    FROM match_results
)

SELECT 
    team,
    MIN(Date) AS streak_start,
    MAX(Date) AS streak_end,
    COUNT(*) AS streak_length
FROM streaks
WHERE is_win = 1
GROUP BY team, streak_group
HAVING COUNT(*) >= 3
ORDER BY streak_length DESC, team;


/* ---------------------------------------------------------
   ANALYSIS 17: Champion profile — what does it take to win?
   Compare rank-1 teams vs everyone else.

   Technique: Multiple CTEs chained together + RANK()
   --------------------------------------------------------- */

WITH yearly_standings AS (
    SELECT 
        team, Year,
        SUM(CASE WHEN result = 'Win' THEN 1 ELSE 0 END) AS wins,
        SUM(CASE WHEN result = 'Loss' THEN 1 ELSE 0 END) AS losses,
        SUM(points_scored) - SUM(points_conceded) AS point_diff,
        ROUND(AVG(points_scored), 1) AS avg_scored,
        ROUND(AVG(points_conceded), 1) AS avg_conceded
    FROM (
        SELECT Year, HomeTeam AS team, HomeScore AS points_scored, AwayScore AS points_conceded,
               CASE WHEN HomeScore > AwayScore THEN 'Win' WHEN HomeScore < AwayScore THEN 'Loss' ELSE 'Draw' END AS result
        FROM six_nations_clean
        UNION ALL
        SELECT Year, AwayTeam AS team, AwayScore AS points_scored, HomeScore AS points_conceded,
               CASE WHEN AwayScore > HomeScore THEN 'Win' WHEN AwayScore < HomeScore THEN 'Loss' ELSE 'Draw' END AS result
        FROM six_nations_clean
    )
    GROUP BY team, Year
),

ranked AS (
    SELECT *, RANK() OVER (PARTITION BY Year ORDER BY wins DESC, point_diff DESC) AS finish_rank
    FROM yearly_standings
)

SELECT 
    CASE WHEN finish_rank = 1 THEN 'Champions' ELSE 'Non-Champions' END AS category,
    COUNT(*) AS team_seasons,
    ROUND(AVG(wins), 1) AS avg_wins,
    ROUND(AVG(losses), 1) AS avg_losses,
    ROUND(AVG(avg_scored), 1) AS avg_pts_per_match,
    ROUND(AVG(avg_conceded), 1) AS avg_pts_conceded,
    ROUND(AVG(point_diff), 1) AS avg_point_differential
FROM ranked
GROUP BY CASE WHEN finish_rank = 1 THEN 'Champions' ELSE 'Non-Champions' END;


/* ---------------------------------------------------------
   ANALYSIS 18: Momentum effect — do win streaks predict wins?
   Teams coming off a win vs coming off a loss.

   Technique: LAG() to check previous match result
   --------------------------------------------------------- */

WITH match_sequence AS (
    SELECT 
        team, Date, result,
        LAG(result, 1) OVER (PARTITION BY team ORDER BY Date) AS prev_result
    FROM (
        SELECT Date, HomeTeam AS team, CASE WHEN HomeScore > AwayScore THEN 'Win' ELSE 'Loss' END AS result FROM six_nations_clean
        UNION ALL
        SELECT Date, AwayTeam AS team, CASE WHEN AwayScore > HomeScore THEN 'Win' ELSE 'Loss' END AS result FROM six_nations_clean
    )
)

SELECT 
    prev_result AS coming_off,
    COUNT(*) AS next_matches,
    SUM(CASE WHEN result = 'Win' THEN 1 ELSE 0 END) AS next_wins,
    ROUND(100.0 * SUM(CASE WHEN result = 'Win' THEN 1 ELSE 0 END) / COUNT(*), 1) AS next_win_pct
FROM match_sequence
WHERE prev_result IS NOT NULL
GROUP BY prev_result
ORDER BY next_win_pct DESC;
