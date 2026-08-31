-- Workforce Data Quality & Analytics
-- Database schema for synthetic workforce source extracts

-- Drop existing tables so the schema can be recreated as needed
DROP TABLE IF EXISTS employee_training;
DROP TABLE IF EXISTS employee_documents;
DROP TABLE IF EXISTS employee_changes;
DROP TABLE IF EXISTS employee_operations;
DROP TABLE IF EXISTS employee_master;


-- Core employee master data
CREATE TABLE employee_master (
    employee_id VARCHAR(10) PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    work_email VARCHAR(100),
    hire_date DATE,
    termination_date DATE,
    employment_status VARCHAR(20),
    employment_type VARCHAR(20),
    job_title VARCHAR(100),
    department VARCHAR(50),
    department_code VARCHAR(20),
    manager_id VARCHAR(10),
    location VARCHAR(50),
    annual_salary NUMERIC(12,2),
    last_updated_date DATE,
    work_arrangement VARCHAR(20)
);


-- Employee onboarding, offboarding, and payroll operations
CREATE TABLE employee_operations (
    employee_id VARCHAR(10),
    onboarding_status VARCHAR(20),
    onboarding_completion_date DATE,
    offboarding_status VARCHAR(20),
    offboarding_completion_date DATE,
    payroll_status VARCHAR(20),
    direct_deposit_status VARCHAR(20),
    tax_form_status VARCHAR(20),
    operations_last_updated DATE
);


-- Employee job, compensation, and status changes
CREATE TABLE employee_changes (
    change_id VARCHAR(10) PRIMARY KEY,
    employee_id VARCHAR(10),
    change_type VARCHAR(50),
    old_value VARCHAR(100),
    new_value VARCHAR(100),
    effective_date DATE,
    request_date DATE,
    processed_date DATE,
    change_status VARCHAR(20)
);


-- Employee documentation and compliance records
CREATE TABLE employee_documents (
    document_id VARCHAR(10) PRIMARY KEY,
    employee_id VARCHAR(10),
    document_type VARCHAR(50),
    document_status VARCHAR(20),
    received_date DATE,
    effective_date DATE,
    expiration_date DATE,
    last_updated_date DATE
);


-- Employee training assignment and completion records
CREATE TABLE employee_training (
    training_record_id VARCHAR(10) PRIMARY KEY,
    employee_id VARCHAR(10),
    training_type VARCHAR(50),
    assigned_date DATE,
    due_date DATE,
    completion_date DATE,
    training_status VARCHAR(20),
    last_updated_date DATE
);
