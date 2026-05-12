-- ============================================================
-- 03_ab_test_summary.sql
-- ============================================================
-- Purpose: Headline summary of A/B test results.
-- Shows each group's user count, retention rates, and engagement.
-- Two versions: full data and outliers excluded.
-- ============================================================


-- Summary 1: Full dataset (including outliers)
SELECT
    version,
    COUNT(*) AS users,

    -- Retention rates as percentages
    ROUND(AVG(retention_1_int) * 100, 2) AS retention_1_pct,
    ROUND(AVG(retention_7_int) * 100, 2) AS retention_7_pct,

    -- Engagement
    ROUND(AVG(sum_gamerounds), 2) AS avg_gamerounds,
    MIN(sum_gamerounds) AS min_gamerounds,
    MAX(sum_gamerounds) AS max_gamerounds

FROM analysis_view
GROUP BY version;


-- Summary 2: Outliers excluded
-- Same query but filters out the suspicious power users
SELECT
    version,
    COUNT(*) AS users,
    ROUND(AVG(retention_1_int) * 100, 2) AS retention_1_pct,
    ROUND(AVG(retention_7_int) * 100, 2) AS retention_7_pct,
    ROUND(AVG(sum_gamerounds), 2) AS avg_gamerounds,
    MIN(sum_gamerounds) AS min_gamerounds,
    MAX(sum_gamerounds) AS max_gamerounds

FROM analysis_view
WHERE is_outlier = 0
GROUP BY version;


-- Summary 3: Side-by-side absolute lift calculation
-- This shows the actual gap between the two groups using a CTE
WITH group_metrics AS (
    SELECT
        version,
        AVG(retention_1_int) * 100 AS r1_pct,
        AVG(retention_7_int) * 100 AS r7_pct,
        AVG(sum_gamerounds) AS avg_rounds
    FROM analysis_view
    WHERE is_outlier = 0
    GROUP BY version
)
SELECT
    ROUND(MAX(CASE WHEN version = 'gate_30' THEN r1_pct END), 2) AS gate_30_r1,
    ROUND(MAX(CASE WHEN version = 'gate_40' THEN r1_pct END), 2) AS gate_40_r1,
    ROUND(MAX(CASE WHEN version = 'gate_40' THEN r1_pct END)
        - MAX(CASE WHEN version = 'gate_30' THEN r1_pct END), 2) AS r1_diff_pp,

    ROUND(MAX(CASE WHEN version = 'gate_30' THEN r7_pct END), 2) AS gate_30_r7,
    ROUND(MAX(CASE WHEN version = 'gate_40' THEN r7_pct END), 2) AS gate_40_r7,
    ROUND(MAX(CASE WHEN version = 'gate_40' THEN r7_pct END)
        - MAX(CASE WHEN version = 'gate_30' THEN r7_pct END), 2) AS r7_diff_pp
FROM group_metrics;