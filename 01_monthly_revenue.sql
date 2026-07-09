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