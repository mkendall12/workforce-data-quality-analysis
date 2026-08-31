-- Workforce Data Quality & Analytics
-- Employee master data quality checks
--
-- These queries identify records that violate or potentially violate
-- expected workforce data business rules and should be investigated
-- before the data is used for downstream reporting or analysis.


-- 1. Terminated employees missing a termination date
-- Business rule: Employees recorded as terminated should have
-- a corresponding termination date.

SELECT
    employee_id,
    first_name,
    last_name,
    employment_status,
    hire_date,
    termination_date
FROM employee_master
WHERE employment_status = 'Terminated'
  AND termination_date IS NULL;


-- 2. Termination dates occurring before hire dates
-- Business rule: An employee's termination date should not precede
-- the employee's hire date.

SELECT
    employee_id,
    first_name,
    last_name,
    employment_status,
    hire_date,
    termination_date
FROM employee_master
WHERE termination_date < hire_date;


-- 3. Review department and department-code mappings
-- Purpose: Profile the unique mappings present in the source data
-- before evaluating inconsistent department/code combinations.

SELECT DISTINCT
    department,
    department_code
FROM employee_master
ORDER BY department;


-- 4. Flag unexpected department-code mappings
-- Business rule: Customer Success should map to CS and Product should map to PROD.
-- Records using other department codes require investigation.

SELECT
    employee_id,
    first_name,
    last_name,
    department,
    department_code
FROM employee_master
WHERE (department = 'Customer Success' AND department_code <> 'CS')
   OR (department = 'Product' AND department_code <> 'PROD');


-- 5. Active employees with a termination date
-- Business rule: Employees recorded as active should not have
-- a termination date populated.

SELECT
    employee_id,
    first_name,
    last_name,
    employment_status,
    termination_date
FROM employee_master
WHERE employment_status = 'Active'
  AND termination_date IS NOT NULL;
