-- ============================================================
-- 03_invoice_line_analysis.sql
-- Invoice Line and Product Revenue Practice Queries
-- Database: Chinook SQLite
-- Goal: Practice multi-table joins, line-item revenue
--       calculations, and product-level summaries.
-- ============================================================


-- ============================================================
-- 1. Invoice line detail
-- ============================================================

SELECT
    i.InvoiceId,
    i.InvoiceDate,
    c.CustomerId,
    c.FirstName || ' ' || c.LastName AS customer_name,
    il.InvoiceLineId,
    t.TrackId,
    t.Name AS track_name,
    il.UnitPrice,
    il.Quantity,
    ROUND(il.UnitPrice * il.Quantity, 2) AS line_revenue
FROM Invoice i
JOIN Customer c
    ON i.CustomerId = c.CustomerId
JOIN InvoiceLine il
    ON i.InvoiceId = il.InvoiceId
JOIN Track t
    ON il.TrackId = t.TrackId
ORDER BY
    i.InvoiceId,
    il.InvoiceLineId;


-- Business explanation:
-- This creates an invoice-detail report with one row per purchased track.
-- Line revenue is calculated from unit price multiplied by quantity.



-- ============================================================
-- 2. Invoice totals calculated from invoice lines
-- ============================================================

SELECT
    i.InvoiceId,
    i.InvoiceDate,
    i.CustomerId,
    COUNT(il.InvoiceLineId) AS line_count,
    SUM(il.Quantity) AS units_purchased,
    ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS calculated_total,
    ROUND(i.Total, 2) AS recorded_invoice_total,
    ROUND(SUM(il.UnitPrice * il.Quantity) - i.Total, 2)
        AS total_difference
FROM Invoice i
JOIN InvoiceLine il
    ON i.InvoiceId = il.InvoiceId
GROUP BY
    i.InvoiceId,
    i.InvoiceDate,
    i.CustomerId,
    i.Total
ORDER BY i.InvoiceId;


-- Business explanation:
-- This reconciles the invoice header total to the sum of its invoice lines.
-- A nonzero difference may indicate incomplete or inconsistent financial data.



-- ============================================================
-- 3. Revenue by track
-- ============================================================

SELECT
    t.TrackId,
    t.Name AS track_name,
    ar.Name AS artist_name,
    SUM(il.Quantity) AS units_sold,
    COUNT(DISTINCT il.InvoiceId) AS invoice_count,
    ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS total_revenue
FROM InvoiceLine il
JOIN Track t
    ON il.TrackId = t.TrackId
JOIN Album al
    ON t.AlbumId = al.AlbumId
JOIN Artist ar
    ON al.ArtistId = ar.ArtistId
GROUP BY
    t.TrackId,
    t.Name,
    ar.Name
ORDER BY
    total_revenue DESC,
    track_name;


-- Business explanation:
-- This shows sales volume and revenue at the individual track level.
-- It can be used to identify the products contributing the most revenue.



-- ============================================================
-- 4. Revenue by album
-- ============================================================

SELECT
    al.AlbumId,
    al.Title AS album_title,
    ar.Name AS artist_name,
    SUM(il.Quantity) AS units_sold,
    COUNT(DISTINCT il.InvoiceId) AS invoice_count,
    ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS total_revenue
FROM InvoiceLine il
JOIN Track t
    ON il.TrackId = t.TrackId
JOIN Album al
    ON t.AlbumId = al.AlbumId
JOIN Artist ar
    ON al.ArtistId = ar.ArtistId
GROUP BY
    al.AlbumId,
    al.Title,
    ar.Name
ORDER BY
    total_revenue DESC,
    album_title;


-- Business explanation:
-- This rolls track-level sales up to the album level.
-- It supports product portfolio reporting at a broader level of detail.



-- ============================================================
-- 5. Revenue by artist
-- ============================================================

SELECT
    ar.ArtistId,
    ar.Name AS artist_name,
    SUM(il.Quantity) AS units_sold,
    COUNT(DISTINCT il.InvoiceId) AS invoice_count,
    ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS total_revenue
FROM InvoiceLine il
JOIN Track t
    ON il.TrackId = t.TrackId
JOIN Album al
    ON t.AlbumId = al.AlbumId
JOIN Artist ar
    ON al.ArtistId = ar.ArtistId
GROUP BY
    ar.ArtistId,
    ar.Name
ORDER BY
    total_revenue DESC,
    artist_name;


-- Business explanation:
-- This summarizes product revenue by artist.
-- It demonstrates joining transactional detail to multiple product dimensions.



-- ============================================================
-- 6. Revenue by genre
-- ============================================================

SELECT
    g.GenreId,
    g.Name AS genre_name,
    SUM(il.Quantity) AS units_sold,
    COUNT(DISTINCT il.InvoiceId) AS invoice_count,
    ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS total_revenue,
    ROUND(AVG(il.UnitPrice), 2) AS average_unit_price
FROM InvoiceLine il
JOIN Track t
    ON il.TrackId = t.TrackId
JOIN Genre g
    ON t.GenreId = g.GenreId
GROUP BY
    g.GenreId,
    g.Name
ORDER BY
    total_revenue DESC,
    genre_name;


-- Business explanation:
-- This compares unit sales, revenue, and average selling price across genres.
-- It can reveal which product categories have the greatest financial contribution.



-- ============================================================
-- 7. Monthly revenue by genre
-- ============================================================

SELECT
    strftime('%Y-%m', i.InvoiceDate) AS invoice_month,
    g.GenreId,
    g.Name AS genre_name,
    SUM(il.Quantity) AS units_sold,
    ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS total_revenue
FROM Invoice i
JOIN InvoiceLine il
    ON i.InvoiceId = il.InvoiceId
JOIN Track t
    ON il.TrackId = t.TrackId
JOIN Genre g
    ON t.GenreId = g.GenreId
GROUP BY
    strftime('%Y-%m', i.InvoiceDate),
    g.GenreId,
    g.Name
ORDER BY
    invoice_month,
    total_revenue DESC,
    genre_name;


-- Business explanation:
-- This adds a time dimension to genre revenue.
-- It can be used to monitor changes in product-category performance by month.



-- ============================================================
-- 8. Top 10 tracks by revenue
-- ============================================================

SELECT
    t.TrackId,
    t.Name AS track_name,
    al.Title AS album_title,
    ar.Name AS artist_name,
    SUM(il.Quantity) AS units_sold,
    ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS total_revenue
FROM InvoiceLine il
JOIN Track t
    ON il.TrackId = t.TrackId
JOIN Album al
    ON t.AlbumId = al.AlbumId
JOIN Artist ar
    ON al.ArtistId = ar.ArtistId
GROUP BY
    t.TrackId,
    t.Name,
    al.Title,
    ar.Name
ORDER BY
    total_revenue DESC,
    track_name
LIMIT 10;


-- Business explanation:
-- This identifies the ten tracks with the highest total line-item revenue.
-- The album and artist fields provide useful context for the ranking.



-- ============================================================
-- 9. Product revenue by customer country
-- ============================================================

SELECT
    c.Country,
    g.Name AS genre_name,
    SUM(il.Quantity) AS units_sold,
    ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS total_revenue
FROM Customer c
JOIN Invoice i
    ON c.CustomerId = i.CustomerId
JOIN InvoiceLine il
    ON i.InvoiceId = il.InvoiceId
JOIN Track t
    ON il.TrackId = t.TrackId
JOIN Genre g
    ON t.GenreId = g.GenreId
GROUP BY
    c.Country,
    g.GenreId,
    g.Name
ORDER BY
    c.Country,
    total_revenue DESC,
    genre_name;


-- Business explanation:
-- This shows which genres generate revenue in each customer country.
-- It combines geographic and product dimensions for market analysis.



-- ============================================================
-- 10. Tracks with no invoice-line sales
-- ============================================================

SELECT
    t.TrackId,
    t.Name AS track_name,
    al.Title AS album_title,
    ar.Name AS artist_name,
    g.Name AS genre_name,
    t.UnitPrice
FROM Track t
JOIN Album al
    ON t.AlbumId = al.AlbumId
JOIN Artist ar
    ON al.ArtistId = ar.ArtistId
LEFT JOIN Genre g
    ON t.GenreId = g.GenreId
LEFT JOIN InvoiceLine il
    ON t.TrackId = il.TrackId
WHERE il.InvoiceLineId IS NULL
ORDER BY
    artist_name,
    album_title,
    track_name;


-- Business explanation:
-- This identifies catalog tracks that have never appeared on an invoice line.
-- It can support product assortment review or source-data completeness checks.
