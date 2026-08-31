# Workforce Data Quality & Analytics

## Overview

This project simulates a workforce data quality and operations workflow for Celestial Ridge Technologies, a fictional ~1,000-person hybrid technology and services company.

The goal is to make workforce data easier to trust, investigate, and use by loading source extracts into PostgreSQL, profiling the data, applying business-rule validations, and reconciling records across related workforce datasets.

The project focuses on identifying data-quality issues before the data is used for downstream reporting or operational processes.

## Project Highlights

- Built a PostgreSQL database from five synthetic workforce datasets containing 5,985 records.
- Developed SQL validation checks for employee lifecycle data, date relationships, department mappings, and other business rules.
- Performed cross-table reconciliation to identify duplicate, unmatched, and inconsistent workforce records.
- Identified data-quality exceptions involving termination data, department mappings, employee IDs, and payroll status.

## Data

The project uses five workforce datasets:
- `data/employee_master.csv` — 1,000 employee records
- `data/employee_operations.csv` — 1,003 operational records
- `data/employee_changes.csv` — 493 employee change records
- `data/employee_documents.csv` — 2,135 document records
- `data/employee_training.csv` — 1,354 training records

These files contain synthetically generated workforce data designed to simulate CSV extracts from multiple employee-management and operational systems. No real employee or company information is included.

## Tools

- PostgreSQL
- SQL
- pgAdmin
- CSV source extracts

## Data Quality Approach

The source tables are intentionally designed to preserve potential data-quality problems rather than prevent every inconsistency during ingestion. This allows validation and reconciliation queries to identify issues that could occur across real operational source systems.

The analysis completed so far includes:

1. Creating a relational PostgreSQL schema for five workforce datasets.
2. Loading and profiling the source extracts.
3. Evaluating employee lifecycle fields using business rules.
4. Identifying missing and logically inconsistent values.
5. Reviewing department and department-code mappings.
6. Detecting duplicate operational records.
7. Reconciling employee IDs across master and operations data.
8. Identifying lifecycle inconsistencies across datasets.

## Key Findings

Initial data-quality and reconciliation checks identified:

- 2 terminated employees with missing termination dates.
- 1 employee with a termination date preceding the hire date.
- 2 suspicious department-code mappings requiring investigation.
- 2 employee IDs with duplicate records in the operations dataset.
- 1 operations record with no corresponding employee in the master dataset.
- 3 terminated employees with active payroll status requiring review.

Reconciliation also explained the difference between the 1,000 employee master records and 1,003 operations records: two additional rows resulted from duplicate employee records and one resulted from an unmatched employee ID.

## SQL Files

- `SQL/01_create_tables.sql` — Creates the PostgreSQL tables used by the project.
- `SQL/02_data_quality_checks.sql` — Performs employee master data-quality checks.
- `SQL/03_reconciliation.sql` — Performs duplicate detection and cross-table reconciliation.

## Next Steps

Planned enhancements include:

- Expanding validation across employee change, document, and training data.
- Reconciling completed employee changes against the employee master dataset.
- Creating a consolidated exception output for operational review.
- Developing summary reporting for workforce data-quality monitoring.
