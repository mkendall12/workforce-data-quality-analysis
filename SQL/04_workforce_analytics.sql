-- Workforce Data Quality & Analytics
-- Workforce Analytics
--
-- Purpose:
-- Analyze workforce composition, hiring and termination activity,
-- turnover, training compliance, and employee changes using the
-- validated workforce data.


-- ============================================================
-- 1. ACTIVE HEADCOUNT BY DEPARTMENT
-- ============================================================
-- Shows how the current active workforce is distributed
-- across departments.

SELECT
    department,
    COUNT(*) AS active_headcount
FROM employee_master
WHERE employment_status = 'Active'
GROUP BY department
ORDER BY active_headcount DESC;


-- ============================================================
-- 2. ACTIVE HEADCOUNT BY LOCATION AND WORK ARRANGEMENT
-- ============================================================
-- Shows where active employees are located and whether they
-- work remotely, hybrid, or on-site.

SELECT
    location,
    work_arrangement,
    COUNT(*) AS active_headcount
FROM employee_master
WHERE employment_status = 'Active'
GROUP BY location, work_arrangement
ORDER BY location, active_headcount DESC;


-- ============================================================
-- 3. MONTHLY HIRING AND TERMINATION TRENDS
-- ============================================================
-- Compares hires and terminations by month to show workforce
-- growth and separation trends over time.

WITH hires AS (
    SELECT
        DATE_TRUNC('month', hire_date)::date AS month,
        COUNT(*) AS hires
    FROM employee_master
    WHERE hire_date IS NOT NULL
    GROUP BY DATE_TRUNC('month', hire_date)
),
terminations AS (
    SELECT
        DATE_TRUNC('month', termination_date)::date AS month,
        COUNT(*) AS terminations
    FROM employee_master
    WHERE termination_date IS NOT NULL
    GROUP BY DATE_TRUNC('month', termination_date)
)
SELECT
    COALESCE(h.month, t.month) AS month,
    COALESCE(h.hires, 0) AS hires,
    COALESCE(t.terminations, 0) AS terminations,
    COALESCE(h.hires, 0) - COALESCE(t.terminations, 0) AS net_change
FROM hires h
FULL OUTER JOIN terminations t
    ON h.month = t.month
ORDER BY month;


-- ============================================================
-- 4. MONTHLY EMPLOYEE TURNOVER RATE
-- ============================================================
-- Calculates turnover for the most recent 12 months in the
-- dataset.
--
-- Turnover rate =
-- terminations during month / average monthly headcount * 100
--
-- Average monthly headcount is estimated using beginning and
-- ending headcount.

WITH reporting_date AS (
    SELECT
        COALESCE(MAX(last_updated_date), CURRENT_DATE) AS snapshot_date
    FROM employee_master
),
months AS (
    SELECT
        GENERATE_SERIES(
            DATE_TRUNC('month', snapshot_date) - INTERVAL '11 months',
            DATE_TRUNC('month', snapshot_date),
            INTERVAL '1 month'
        )::date AS month_start
    FROM reporting_date
),
workforce_metrics AS (
    SELECT
        m.month_start,

        (
            SELECT COUNT(*)
            FROM employee_master e
            WHERE e.hire_date < m.month_start
              AND (
                    e.termination_date IS NULL
                    OR e.termination_date >= m.month_start
                  )
        ) AS beginning_headcount,

        (
            SELECT COUNT(*)
            FROM employee_master e
            WHERE e.hire_date < (m.month_start + INTERVAL '1 month')
              AND (
                    e.termination_date IS NULL
                    OR e.termination_date >=
                       (m.month_start + INTERVAL '1 month')
                  )
        ) AS ending_headcount,

        (
            SELECT COUNT(*)
            FROM employee_master e
            WHERE e.termination_date >= m.month_start
              AND e.termination_date <
                  (m.month_start + INTERVAL '1 month')
        ) AS terminations

    FROM months m
)
SELECT
    month_start AS month,
    beginning_headcount,
    ending_headcount,
    terminations,
    ROUND(
        (
            terminations /
            NULLIF(
                (beginning_headcount + ending_headcount) / 2.0,
                0
            )
        ) * 100,
        2
    ) AS turnover_rate_pct
FROM workforce_metrics
ORDER BY month;


-- ============================================================
-- 5. TRAINING COMPLIANCE BY TRAINING TYPE
-- ============================================================
-- Measures training completion and overdue assignments.
-- The latest date in the training dataset is used as the
-- reporting date so results remain reproducible over time.

WITH reporting_date AS (
    SELECT
        COALESCE(MAX(last_updated_date), CURRENT_DATE) AS snapshot_date
    FROM employee_training
)
SELECT
    t.training_type,
    COUNT(*) AS assigned_records,

    COUNT(*) FILTER (
        WHERE t.completion_date IS NOT NULL
    ) AS completed_records,

    COUNT(*) FILTER (
        WHERE t.completion_date IS NULL
          AND t.due_date < r.snapshot_date
    ) AS overdue_records,

    ROUND(
        COUNT(*) FILTER (
            WHERE t.completion_date IS NOT NULL
        )::numeric
        / NULLIF(COUNT(*), 0) * 100,
        2
    ) AS completion_rate_pct

FROM employee_training t
CROSS JOIN reporting_date r
GROUP BY t.training_type
ORDER BY completion_rate_pct DESC;


-- ============================================================
-- 6. EMPLOYEE CHANGES BY TYPE
-- ============================================================
-- Summarizes employee lifecycle activity such as compensation,
-- job, department, or employment-status changes.

SELECT
    change_type,
    COUNT(*) AS total_changes,
    COUNT(DISTINCT employee_id) AS employees_affected
FROM employee_changes
GROUP BY change_type
ORDER BY total_changes DESC;
