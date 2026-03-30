{{ config(materialized='table') }}

-- Daily complaint volume, ordered chronologically.
-- Drives the time-series line chart in the dashboard.

SELECT
    DATE(created_date) AS request_date,
    COUNT(*)           AS total_requests
FROM {{ ref('stg_311_requests') }}
WHERE created_date IS NOT NULL
GROUP BY request_date
ORDER BY request_date
