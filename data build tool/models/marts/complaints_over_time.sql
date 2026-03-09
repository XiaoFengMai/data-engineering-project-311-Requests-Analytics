# filters complaint over time within dashboard chart
SELECT
    DATE(created_date) AS request_date,
    COUNT(*) AS total_requests
FROM {{ ref('stg_311_requests') }}
GROUP BY request_date
ORDER BY request_date
