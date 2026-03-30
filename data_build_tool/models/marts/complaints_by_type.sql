{{ config(materialized='table') }}

-- Aggregated complaint counts by type, ordered highest to lowest.
-- Drives the bar chart in the Looker Studio / Streamlit dashboard.

SELECT
    complaint_type,
    COUNT(*) AS total_requests
FROM {{ ref('int_311_cleaned') }}
GROUP BY complaint_type
ORDER BY total_requests DESC
