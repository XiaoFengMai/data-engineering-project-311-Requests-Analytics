-- aggregates 311 service requests over time within dashboard chart

SELECT
    DATE(created_date) AS request_date,            -- converts a full timestamp to just the date so ex: 2024-03-02 14:22:00 to just 2024-03-02 
    COUNT(*) AS total_requests                    -- renames the result column to total_requests
FROM {{ ref('stg_311_requests') }}                    -- pulls from stg_311_requests staging model using dbt's ref function
GROUP BY request_date                        -- groups all rows by date so count(*) is calculated per day rather than across whole table
ORDER BY request_date                    -- sorts results chronologically oldest -> newest, ascending order
