-- ============================================================
-- 01_monthly_revenue.sql
-- Monthly Revenue Practice Queries
-- Database: Chinook SQLite
-- Goal: Practice financial reporting, monthly summaries,
--       trends, and variance-style analysis.
-- ============================================================


-- ============================================================
-- 1. Basic monthly revenue summary
-- ============================================================

SELECT
    strftime('%Y-%m', InvoiceDate) AS invoice_month,
    COUNT(*) AS invoice_count,
    ROUND(SUM(Total), 2) AS total_revenue,
    ROUND(AVG(Total), 2) AS average_invoice_total
FROM Invoice
GROUP BY strftime('%Y-%m', InvoiceDate)
ORDER BY invoice_month;


-- Business explanation:
-- This summarizes total revenue, number of invoices, and average invoice value by month.
-- This is the basic structure of a recurring monthly financial report.



-- ============================================================
-- 2. Monthly revenue by billing country
-- ============================================================

SELECT
    strftime('%Y-%m', InvoiceDate) AS invoice_month,
    BillingCountry,
    COUNT(*) AS invoice_count,
    ROUND(SUM(Total), 2) AS total_revenue
FROM Invoice
GROUP BY
    strftime('%Y-%m', InvoiceDate),
    BillingCountry
ORDER BY
    invoice_month,
    total_revenue DESC;


-- Business explanation:
-- This shows which countries contributed the most revenue each month.



-- ============================================================
-- 3. Revenue by year and month separately
-- ============================================================

SELECT
    strftime('%Y', InvoiceDate) AS invoice_year,
    strftime('%m', InvoiceDate) AS invoice_month_number,
    COUNT(*) AS invoice_count,
    ROUND(SUM(Total), 2) AS total_revenue
FROM Invoice
GROUP BY
    strftime('%Y', InvoiceDate),
    strftime('%m', InvoiceDate)
ORDER BY
    invoice_year,
    invoice_month_number;


-- Business explanation:
-- This is useful when a report needs separate year and month fields,
-- especially for pivot tables, dashboards, or Excel exports.



-- ============================================================
-- 4. Monthly revenue with month-over-month change
-- ============================================================

WITH monthly_revenue AS (
    SELECT
        strftime('%Y-%m', InvoiceDate) AS invoice_month,
        ROUND(SUM(Total), 2) AS total_revenue
    FROM Invoice
    GROUP BY strftime('%Y-%m', InvoiceDate)
)

SELECT
    invoice_month,
    total_revenue,
    LAG(total_revenue) OVER (
        ORDER BY invoice_month
    ) AS previous_month_revenue,
    ROUND(
        total_revenue - LAG(total_revenue) OVER (
            ORDER BY invoice_month
        ),
        2
    ) AS revenue_change
FROM monthly_revenue
ORDER BY invoice_month;


-- Business explanation:
-- This compares each month’s revenue to the prior month.
-- It is useful for identifying increases or decreases in revenue over time.



-- ============================================================
-- 5. Monthly revenue with month-over-month percent change
-- ============================================================

WITH monthly_revenue AS (
    SELECT
        strftime('%Y-%m', InvoiceDate) AS invoice_month,
        ROUND(SUM(Total), 2) AS total_revenue
    FROM Invoice
    GROUP BY strftime('%Y-%m', InvoiceDate)
),

monthly_comparison AS (
    SELECT
        invoice_month,
        total_revenue,
        LAG(total_revenue) OVER (
            ORDER BY invoice_month
        ) AS previous_month_revenue
    FROM monthly_revenue
)

SELECT
    invoice_month,
    total_revenue,
    previous_month_revenue,
    ROUND(total_revenue - previous_month_revenue, 2) AS revenue_change,
    ROUND(
        100.0 * (total_revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0),
        2
    ) AS revenue_percent_change
FROM monthly_comparison
ORDER BY invoice_month;


-- Business explanation:
-- This calculates both dollar change and percent change from the prior month.
-- NULLIF prevents division by zero.



-- ============================================================
-- 6. Monthly revenue by customer
-- ============================================================

SELECT
    strftime('%Y-%m', i.InvoiceDate) AS invoice_month,
    c.CustomerId,
    c.FirstName || ' ' || c.LastName AS customer_name,
    c.Country,
    COUNT(i.InvoiceId) AS invoice_count,
    ROUND(SUM(i.Total), 2) AS total_revenue
FROM Invoice i
JOIN Customer c
    ON i.CustomerId = c.CustomerId
GROUP BY
    strftime('%Y-%m', i.InvoiceDate),
    c.CustomerId,
    customer_name,
    c.Country
ORDER BY
    invoice_month,
    total_revenue DESC;


-- Business explanation:
-- This shows monthly revenue at the customer level.
-- It could help identify top customers or customer-level trends.



-- ============================================================
-- 7. Top revenue month
-- ============================================================

SELECT
    strftime('%Y-%m', InvoiceDate) AS invoice_month,
    ROUND(SUM(Total), 2) AS total_revenue
FROM Invoice
GROUP BY strftime('%Y-%m', InvoiceDate)
ORDER BY total_revenue DESC
LIMIT 1;


-- Business explanation:
-- This identifies the highest revenue month in the data.



-- ============================================================
-- 8. Monthly revenue ranked from highest to lowest
-- ============================================================

WITH monthly_revenue AS (
    SELECT
        strftime('%Y-%m', InvoiceDate) AS invoice_month,
        ROUND(SUM(Total), 2) AS total_revenue
    FROM Invoice
    GROUP BY strftime('%Y-%m', InvoiceDate)
)

SELECT
    invoice_month,
    total_revenue,
    RANK() OVER (
        ORDER BY total_revenue DESC
    ) AS revenue_rank
FROM monthly_revenue
ORDER BY revenue_rank;


-- Business explanation:
-- This ranks each month by total revenue.
-- It combines aggregation with a window function.



-- ============================================================
-- 9. Monthly revenue by sales support representative
-- ============================================================

SELECT
    strftime('%Y-%m', i.InvoiceDate) AS invoice_month,
    e.FirstName || ' ' || e.LastName AS sales_rep,
    COUNT(i.InvoiceId) AS invoice_count,
    ROUND(SUM(i.Total), 2) AS total_revenue
FROM Invoice i
JOIN Customer c
    ON i.CustomerId = c.CustomerId
JOIN Employee e
    ON c.SupportRepId = e.EmployeeId
GROUP BY
    strftime('%Y-%m', i.InvoiceDate),
    sales_rep
ORDER BY
    invoice_month,
    total_revenue DESC;


-- Business explanation:
-- This summarizes monthly revenue by support representative.
-- In a finance/reporting role, this is similar to revenue by business unit,
-- manager, product owner, or account group.



-- ============================================================
-- 10. Monthly revenue data quality check
-- ============================================================

SELECT
    InvoiceId,
    CustomerId,
    InvoiceDate,
    Total
FROM Invoice
WHERE Total IS NULL
   OR Total < 0
   OR InvoiceDate IS NULL;


-- Business explanation:
-- Before building a financial report, it is important to check for missing,
-- negative, or invalid financial values.