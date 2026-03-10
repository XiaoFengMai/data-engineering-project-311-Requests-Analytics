# this query filters complaint types displayed within looker dashboard charts
SELECT
    complaint_type,
    COUNT(*) AS total_requests
FROM {{ ref('stg_311_cleaned') }}
GROUP BY complaint_type
ORDER BY total_requests DESC
