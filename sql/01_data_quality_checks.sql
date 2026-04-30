-- ============================================================
-- 01_data_quality_checks.sql
-- ============================================================
-- Purpose: Validate the Cookie Cats dataset before any analysis.
-- Run these checks first. If any fail, fix the data before
-- moving on to the actual analysis.
-- ============================================================


-- Check 1: Total row count
-- Confirming all 90,189 rows loaded.
SELECT COUNT(*) AS total_rows
FROM experiment_data;


-- Check 2: Group split (control vs treatment)
-- Want this to be roughly 50/50.
SELECT
    version,
    COUNT(*) AS users,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct
FROM experiment_data
GROUP BY version;


-- Check 3: Duplicate user IDs
-- Each user should appear exactly once. Empty result = no duplicates.
SELECT
    userid,
    COUNT(*) AS times_appearing
FROM experiment_data
GROUP BY userid
HAVING COUNT(*) > 1;


-- Check 4: Null value counts per column
-- All should be 0.
SELECT
    SUM(CASE WHEN userid IS NULL THEN 1 ELSE 0 END) AS null_userid,
    SUM(CASE WHEN version IS NULL THEN 1 ELSE 0 END) AS null_version,
    SUM(CASE WHEN sum_gamerounds IS NULL THEN 1 ELSE 0 END) AS null_sum_gamerounds,
    SUM(CASE WHEN retention_1 IS NULL THEN 1 ELSE 0 END) AS null_retention_1,
    SUM(CASE WHEN retention_7 IS NULL THEN 1 ELSE 0 END) AS null_retention_7
FROM experiment_data;


-- Check 5: Users assigned to both groups
-- Critical A/B test integrity check. Should be empty.
SELECT
    userid,
    COUNT(DISTINCT version) AS num_versions
FROM experiment_data
GROUP BY userid
HAVING COUNT(DISTINCT version) > 1;


-- Check 6a: Game rounds distribution by group
-- Looking for outliers in the max value.
SELECT
    version,
    MIN(sum_gamerounds) AS min_rounds,
    MAX(sum_gamerounds) AS max_rounds,
    ROUND(AVG(sum_gamerounds), 2) AS avg_rounds,
    COUNT(*) AS total_users
FROM experiment_data
GROUP BY version;


-- Check 6b: Investigate the extreme outliers
-- One user supposedly played 49,854 rounds. Likely a bot or test account.
SELECT *
FROM experiment_data
WHERE sum_gamerounds > 5000
ORDER BY sum_gamerounds DESC;


-- Check 7: Retention values are valid (True/False only)
-- Should see exactly 4 rows: TT, TF, FT, FF.
SELECT
    retention_1,
    retention_7,
    COUNT(*) AS users
FROM experiment_data
GROUP BY retention_1, retention_7;