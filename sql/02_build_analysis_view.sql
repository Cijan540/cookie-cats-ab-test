-- ============================================================
-- 02_build_analysis_view.sql
-- ============================================================
-- Purpose: Create an analysis-ready view of the data.
-- Adds derived columns: engagement segment, outlier flag,
-- and integer versions of retention booleans (easier for stats).
-- ============================================================


-- Drop the view if it already exists (lets us re-run this script)
DROP VIEW IF EXISTS analysis_view;


CREATE VIEW analysis_view AS
SELECT
    userid,
    version,
    sum_gamerounds,
    retention_1,
    retention_7,

    -- Convert True/False to 1/0 for math operations
    CASE WHEN retention_1 = 'True' OR retention_1 = 1 THEN 1 ELSE 0 END AS retention_1_int,
    CASE WHEN retention_7 = 'True' OR retention_7 = 1 THEN 1 ELSE 0 END AS retention_7_int,

    -- Flag obvious outliers (anything above 5000 rounds is suspicious)
    CASE WHEN sum_gamerounds > 5000 THEN 1 ELSE 0 END AS is_outlier,

    -- Engagement segments based on rounds played
    CASE
        WHEN sum_gamerounds = 0 THEN 'never_played'
        WHEN sum_gamerounds BETWEEN 1 AND 10 THEN 'light'
        WHEN sum_gamerounds BETWEEN 11 AND 50 THEN 'medium'
        WHEN sum_gamerounds BETWEEN 51 AND 200 THEN 'heavy'
        ELSE 'power_user'
    END AS engagement_segment

FROM experiment_data;