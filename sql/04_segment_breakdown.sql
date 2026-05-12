-- ============================================================
-- 04_segment_breakdown.sql
-- ============================================================
-- Purpose: Break down A/B test results by player engagement segment.
-- Reveals whether the overall result is consistent or driven by
-- specific user groups.
-- ============================================================


-- Query 1: User distribution by segment and group
-- Sanity check that both groups have similar segment makeup
SELECT
    engagement_segment,
    SUM(CASE WHEN version = 'gate_30' THEN 1 ELSE 0 END) AS gate_30_users,
    SUM(CASE WHEN version = 'gate_40' THEN 1 ELSE 0 END) AS gate_40_users,
    COUNT(*) AS total_users
FROM analysis_view
WHERE is_outlier = 0
GROUP BY engagement_segment
ORDER BY total_users DESC;


-- Query 2: Day-7 retention by segment and group
-- The key question: does the gate_30 advantage hold for every segment?
SELECT
    engagement_segment,
    ROUND(AVG(CASE WHEN version = 'gate_30' THEN retention_7_int END) * 100, 2) AS gate_30_r7_pct,
    ROUND(AVG(CASE WHEN version = 'gate_40' THEN retention_7_int END) * 100, 2) AS gate_40_r7_pct,
    ROUND(
        (AVG(CASE WHEN version = 'gate_40' THEN retention_7_int END) -
         AVG(CASE WHEN version = 'gate_30' THEN retention_7_int END)) * 100,
        2
    ) AS diff_pp
FROM analysis_view
WHERE is_outlier = 0
GROUP BY engagement_segment
ORDER BY
    CASE engagement_segment
        WHEN 'never_played' THEN 1
        WHEN 'light' THEN 2
        WHEN 'medium' THEN 3
        WHEN 'heavy' THEN 4
        WHEN 'power_user' THEN 5
    END;


-- Query 3: Day-1 retention by segment and group
-- Same breakdown but for the early-funnel guardrail
SELECT
    engagement_segment,
    ROUND(AVG(CASE WHEN version = 'gate_30' THEN retention_1_int END) * 100, 2) AS gate_30_r1_pct,
    ROUND(AVG(CASE WHEN version = 'gate_40' THEN retention_1_int END) * 100, 2) AS gate_40_r1_pct,
    ROUND(
        (AVG(CASE WHEN version = 'gate_40' THEN retention_1_int END) -
         AVG(CASE WHEN version = 'gate_30' THEN retention_1_int END)) * 100,
        2
    ) AS diff_pp
FROM analysis_view
WHERE is_outlier = 0
GROUP BY engagement_segment
ORDER BY
    CASE engagement_segment
        WHEN 'never_played' THEN 1
        WHEN 'light' THEN 2
        WHEN 'medium' THEN 3
        WHEN 'heavy' THEN 4
        WHEN 'power_user' THEN 5
    END;