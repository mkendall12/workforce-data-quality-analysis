-- Workforce Data Quality & Analytics
-- Cross-table reconciliation checks
--
-- These queries compare employee master and operations data to identify
-- duplicate records, unmatched employee IDs, and lifecycle inconsistencies.


-- 1. Compare total record counts between master and operations
-- Purpose: Quantify the difference between the two datasets before
-- investigating duplicates and unmatched records.

SELECT
    (SELECT COUNT(*) FROM employee_master) AS master_record_count,
    (SELECT COUNT(*) FROM employee_operations) AS operations_record_count;


-- 2. Identify duplicate employee records in the operations dataset
-- Business rule: Each employee should have one current operations record.

SELECT
    employee_id,
    COUNT(*) AS record_count
FROM employee_operations
GROUP BY employee_id
HAVING COUNT(*) > 1;


-- 3. Identify master employees missing from operations
-- Purpose: Confirm that each employee in the master dataset has a
-- corresponding operations record.

SELECT
    m.employee_id,
    m.first_name,
    m.last_name
FROM employee_master m
LEFT JOIN employee_operations o
    ON m.employee_id = o.employee_id
WHERE o.employee_id IS NULL;


-- 4. Identify operations records without a corresponding master employee
-- Business rule: Every operations record should correspond to a valid
-- employee in the master dataset.

SELECT
    o.employee_id
FROM employee_operations o
LEFT JOIN employee_master m
    ON o.employee_id = m.employee_id
WHERE m.employee_id IS NULL;


-- 5. Identify terminated employees with active payroll status
-- Purpose: Flag lifecycle inconsistencies requiring investigation before
-- payroll or workforce reporting processes rely on the records.

SELECT
    m.employee_id,
    m.first_name,
    m.last_name,
    m.employment_status,
    o.payroll_status
FROM employee_master m
JOIN employee_operations o
    ON m.employee_id = o.employee_id
WHERE m.employment_status = 'Terminated'
  AND o.payroll_status = 'Active';
