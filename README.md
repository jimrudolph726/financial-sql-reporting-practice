# Financial SQL Reporting Practice

This repository contains SQL queries written to practice business and financial reporting workflows. The examples focus on using SQL to summarize revenue, validate data, analyze customers, inspect invoice-level activity, and build repeatable reporting-style queries.

The goal of this project is to demonstrate how SQL can be used not only to retrieve data, but also to support reliable reporting, data quality review, and business decision-making.

## Purpose

This project was created as part of my continued development as a data analyst. The queries are designed around practical analyst tasks such as:

* Monthly revenue reporting
* Customer revenue analysis
* Invoice and invoice line analysis
* Duplicate and missing record checks
* Data quality validation
* Prior-period comparisons
* Window function practice
* Business-focused SQL documentation

Rather than treating SQL as an isolated technical skill, this repository focuses on applying SQL to realistic reporting and analysis scenarios.

## Tools Used

* DataGrip
* SQLite
* SQL
* GitHub

## Database

The queries in this repository are written using the Chinook SQLite database located here: https://github.com/lerocha/chinook-database/tree/master.
The database contains tables such as:

* `Customer`
* `Invoice`
* `InvoiceLine`
* `Track`
* `Album`
* `Artist`
* `Employee`
* `Genre`

This structure allows for practice with customer-level analysis, invoice summaries, sales trends, joins, aggregations, and reporting-style queries.

## Repository Structure

```text
financial-sql-reporting-practice/
    README.md
    01_monthly_revenue.sql
    02_customer_revenue_analysis.sql
    03_invoice_line_analysis.sql
    04_data_quality_checks.sql (upcoming)
    05_window_functions.sql (upcoming)
    06_variance_analysis.sql (upcoming)
    07_interview_challenges.sql (upcoming)
```

## Query Topics

### 01_monthly_revenue.sql

Monthly revenue summaries and trend analysis.
Examples include total revenue by month, invoice counts, average invoice totals, and month-over-month revenue changes.

Skills demonstrated:

* `GROUP BY`
* `SUM`
* `COUNT`
* `AVG`
* date formatting
* common table expressions
* window functions

### 02_customer_revenue_analysis.sql

Customer-level revenue analysis.
Examples include lifetime customer value, revenue by country, customer invoice counts, and identifying top customers.

Skills demonstrated:

* `JOIN`
* customer-level aggregation
* ordering and ranking
* business segmentation

### 03_invoice_line_analysis.sql

Invoice line and product-level analysis.
Examples include revenue by track, album, artist, genre, and invoice detail.

Skills demonstrated:

* multi-table joins
* line-item analysis
* product-level summaries
* revenue calculations

### 04_data_quality_checks.sql (Upcoming)

Queries for identifying potential data issues before reporting.
Examples include missing values, duplicate records, orphaned records, and unexpected financial values.

Skills demonstrated:

* `LEFT JOIN`
* `HAVING`
* null checks
* duplicate detection
* validation logic

### 05_window_functions.sql (Upcoming)

Window function examples for reporting and analysis.
Examples include running totals, prior invoice comparisons, ranking, and customer-level sequence analysis.

Skills demonstrated:

* `LAG`
* `LEAD`
* `ROW_NUMBER`
* `RANK`
* `SUM() OVER`
* `PARTITION BY`

### 06_variance_analysis.sql (Upcoming)

Queries focused on variance-style reporting.
Examples include comparing actual values to prior periods, calculating dollar changes, and calculating percentage changes.

Skills demonstrated:

* common table expressions
* prior-period comparison
* percent change calculations
* `NULLIF` for divide-by-zero protection

### 07_interview_challenges.sql (Upcoming)

Practice queries designed around common SQL interview topics for data analyst roles.

Skills demonstrated:

* joins
* aggregations
* filtering
* grouping
* subqueries
* window functions
* explaining SQL in business terms

## Example Query

```sql
SELECT
    strftime('%Y-%m', InvoiceDate) AS invoice_month,
    COUNT(*) AS invoice_count,
    ROUND(SUM(Total), 2) AS total_revenue,
    ROUND(AVG(Total), 2) AS average_invoice_total
FROM Invoice
GROUP BY strftime('%Y-%m', InvoiceDate)
ORDER BY invoice_month;
```

## Business Explanation

This query summarizes invoice activity by month. It calculates the total number of invoices, total revenue, and average invoice amount for each month. This type of query could be used as the foundation for a recurring monthly financial reporting package.

## Skills Demonstrated

This repository demonstrates practical SQL skills including:

* Selecting and filtering records
* Joining relational tables
* Aggregating financial data
* Grouping by month, customer, country, and product category
* Creating business summaries from transactional data
* Checking for duplicate and missing records
* Using common table expressions
* Using window functions
* Calculating dollar and percent changes
* Writing SQL with clear business purpose and documentation

## Why This Project Matters

Financial and business reporting depends on clean, reliable, and well-structured data. This project demonstrates how SQL can be used to validate source data, summarize key metrics, and create repeatable reporting logic.

The emphasis is on writing queries that are not only technically correct, but also understandable, reusable, and connected to real business questions.
