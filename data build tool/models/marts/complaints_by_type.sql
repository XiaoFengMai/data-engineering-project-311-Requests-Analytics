# this sql query is used to power looker dashboard charts
SELECT
    complaint_type,
    COUNT(*) AS total_requests
FROM {{ ref('stg_311_requests') }}
GROUP BY complaint_type
ORDER BY total_requests DESC

