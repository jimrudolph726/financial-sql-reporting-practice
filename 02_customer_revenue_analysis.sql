-- ============================================================
-- 02_customer_revenue_analysis.sql
-- Customer Revenue Analysis Practice Queries
-- Database: Chinook SQLite
-- Goal: Practice customer-level aggregation, ranking,
--       segmentation, and business-focused revenue analysis.
-- ============================================================


-- ============================================================
-- 1. Lifetime revenue by customer
-- ============================================================

SELECT
    c.CustomerId,
    c.FirstName || ' ' || c.LastName AS customer_name,
    c.Country,
    COUNT(i.InvoiceId) AS invoice_count,
    ROUND(SUM(i.Total), 2) AS lifetime_revenue
FROM Customer c
JOIN Invoice i
    ON c.CustomerId = i.CustomerId
GROUP BY
    c.CustomerId,
    c.FirstName,
    c.LastName,
    c.Country
ORDER BY
    lifetime_revenue DESC,
    customer_name;


-- Business explanation:
-- This summarizes the total invoiced revenue and invoice count for each customer.
-- It can be used as a basic customer lifetime value report.



-- ============================================================
-- 2. Customer invoice activity and average invoice value
-- ============================================================

SELECT
    c.CustomerId,
    c.FirstName || ' ' || c.LastName AS customer_name,
    COUNT(i.InvoiceId) AS invoice_count,
    ROUND(SUM(i.Total), 2) AS total_revenue,
    ROUND(AVG(i.Total), 2) AS average_invoice_value,
    ROUND(MIN(i.Total), 2) AS smallest_invoice,
    ROUND(MAX(i.Total), 2) AS largest_invoice
FROM Customer c
JOIN Invoice i
    ON c.CustomerId = i.CustomerId
GROUP BY
    c.CustomerId,
    c.FirstName,
    c.LastName
ORDER BY
    total_revenue DESC,
    customer_name;


-- Business explanation:
-- This provides a customer-level view of purchase frequency and invoice size.
-- The minimum, maximum, and average values help describe each customer's activity.



-- ============================================================
-- 3. Revenue by customer country
-- ============================================================

SELECT
    c.Country,
    COUNT(DISTINCT c.CustomerId) AS customer_count,
    COUNT(i.InvoiceId) AS invoice_count,
    ROUND(SUM(i.Total), 2) AS total_revenue,
    ROUND(SUM(i.Total) / COUNT(DISTINCT c.CustomerId), 2)
        AS revenue_per_customer
FROM Customer c
JOIN Invoice i
    ON c.CustomerId = i.CustomerId
GROUP BY c.Country
ORDER BY
    total_revenue DESC,
    c.Country;


-- Business explanation:
-- This compares total revenue and revenue per customer across countries.
-- It helps distinguish large markets from markets with high-value customers.



-- ============================================================
-- 4. Top 10 customers by lifetime revenue
-- ============================================================

SELECT
    c.CustomerId,
    c.FirstName || ' ' || c.LastName AS customer_name,
    c.Company,
    c.Country,
    ROUND(SUM(i.Total), 2) AS lifetime_revenue
FROM Customer c
JOIN Invoice i
    ON c.CustomerId = i.CustomerId
GROUP BY
    c.CustomerId,
    c.FirstName,
    c.LastName,
    c.Company,
    c.Country
ORDER BY
    lifetime_revenue DESC,
    customer_name
LIMIT 10;


-- Business explanation:
-- This identifies the ten customers who generated the most invoiced revenue.
-- A report like this can support account prioritization and retention analysis.



-- ============================================================
-- 5. Customer revenue ranking within each country
-- ============================================================

WITH customer_revenue AS (
    SELECT
        c.CustomerId,
        c.FirstName || ' ' || c.LastName AS customer_name,
        c.Country,
        ROUND(SUM(i.Total), 2) AS total_revenue
    FROM Customer c
    JOIN Invoice i
        ON c.CustomerId = i.CustomerId
    GROUP BY
        c.CustomerId,
        c.FirstName,
        c.LastName,
        c.Country
)

SELECT
    CustomerId,
    customer_name,
    Country,
    total_revenue,
    RANK() OVER (
        PARTITION BY Country
        ORDER BY total_revenue DESC
    ) AS country_revenue_rank
FROM customer_revenue
ORDER BY
    Country,
    country_revenue_rank,
    customer_name;


-- Business explanation:
-- This ranks customers against other customers in the same country.
-- RANK preserves ties when customers have equal lifetime revenue.



-- ============================================================
-- 6. Customer revenue segmentation
-- ============================================================

WITH customer_revenue AS (
    SELECT
        c.CustomerId,
        c.FirstName || ' ' || c.LastName AS customer_name,
        c.Country,
        ROUND(SUM(i.Total), 2) AS total_revenue
    FROM Customer c
    JOIN Invoice i
        ON c.CustomerId = i.CustomerId
    GROUP BY
        c.CustomerId,
        c.FirstName,
        c.LastName,
        c.Country
),

segmented_customers AS (
    SELECT
        CustomerId,
        customer_name,
        Country,
        total_revenue,
        NTILE(4) OVER (
            ORDER BY total_revenue DESC
        ) AS revenue_quartile
    FROM customer_revenue
)

SELECT
    CustomerId,
    customer_name,
    Country,
    total_revenue,
    CASE revenue_quartile
        WHEN 1 THEN 'High value'
        WHEN 2 THEN 'Upper-middle value'
        WHEN 3 THEN 'Lower-middle value'
        WHEN 4 THEN 'Lower value'
    END AS customer_segment
FROM segmented_customers
ORDER BY
    revenue_quartile,
    total_revenue DESC,
    customer_name;


-- Business explanation:
-- This divides customers into four relative revenue segments.
-- Relative segments adapt to the data instead of relying on arbitrary dollar limits.



-- ============================================================
-- 7. First and most recent invoice by customer
-- ============================================================

SELECT
    c.CustomerId,
    c.FirstName || ' ' || c.LastName AS customer_name,
    MIN(i.InvoiceDate) AS first_invoice_date,
    MAX(i.InvoiceDate) AS most_recent_invoice_date,
    COUNT(i.InvoiceId) AS invoice_count,
    ROUND(SUM(i.Total), 2) AS total_revenue
FROM Customer c
LEFT JOIN Invoice i
    ON c.CustomerId = i.CustomerId
GROUP BY
    c.CustomerId,
    c.FirstName,
    c.LastName
ORDER BY
    most_recent_invoice_date DESC,
    customer_name;


-- Business explanation:
-- This shows the observed customer relationship period and purchase activity.
-- The LEFT JOIN also keeps customers who do not have an invoice in the result.



-- ============================================================
-- 8. Customers above average lifetime revenue
-- ============================================================

WITH customer_revenue AS (
    SELECT
        c.CustomerId,
        c.FirstName || ' ' || c.LastName AS customer_name,
        c.Country,
        ROUND(SUM(i.Total), 2) AS total_revenue
    FROM Customer c
    JOIN Invoice i
        ON c.CustomerId = i.CustomerId
    GROUP BY
        c.CustomerId,
        c.FirstName,
        c.LastName,
        c.Country
)

SELECT
    CustomerId,
    customer_name,
    Country,
    total_revenue,
    ROUND((SELECT AVG(total_revenue) FROM customer_revenue), 2)
        AS average_customer_revenue
FROM customer_revenue
WHERE total_revenue > (
    SELECT AVG(total_revenue)
    FROM customer_revenue
)
ORDER BY
    total_revenue DESC,
    customer_name;


-- Business explanation:
-- This identifies customers whose lifetime revenue is above the customer average.
-- It demonstrates comparing detail rows with an overall business benchmark.



-- ============================================================
-- 9. Customer revenue by sales support representative
-- ============================================================

SELECT
    e.EmployeeId,
    e.FirstName || ' ' || e.LastName AS sales_rep,
    COUNT(DISTINCT c.CustomerId) AS customer_count,
    COUNT(i.InvoiceId) AS invoice_count,
    ROUND(SUM(i.Total), 2) AS total_revenue,
    ROUND(SUM(i.Total) / COUNT(DISTINCT c.CustomerId), 2)
        AS revenue_per_customer
FROM Employee e
JOIN Customer c
    ON e.EmployeeId = c.SupportRepId
JOIN Invoice i
    ON c.CustomerId = i.CustomerId
GROUP BY
    e.EmployeeId,
    e.FirstName,
    e.LastName
ORDER BY
    total_revenue DESC,
    sales_rep;


-- Business explanation:
-- This rolls customer revenue up to the assigned support representative.
-- It resembles revenue reporting by account owner or business unit.



-- ============================================================
-- 10. Customers with no invoices
-- ============================================================

SELECT
    c.CustomerId,
    c.FirstName || ' ' || c.LastName AS customer_name,
    c.Email,
    c.Country
FROM Customer c
LEFT JOIN Invoice i
    ON c.CustomerId = i.CustomerId
WHERE i.InvoiceId IS NULL
ORDER BY
    c.Country,
    customer_name;


-- Business explanation:
-- This data quality and activity check identifies customer records with no invoices.
-- Such records may be valid prospects or may require review before customer reporting.
