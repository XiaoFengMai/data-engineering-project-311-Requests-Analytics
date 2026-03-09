# filters out complaints by borough within dashboard charts

SELECT
    borough,
    COUNT(*) AS total_requests
FROM {{ ref('stg_311_requests') }}
GROUP BY borough
ORDER BY total_requests DESC
