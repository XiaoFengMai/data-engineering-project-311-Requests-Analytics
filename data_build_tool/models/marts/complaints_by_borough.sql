-- aggregates 311 service requests by borough within dashboard charts
-- answers "how many 311 complaints were filed in each NYC borough, from most to least?

SELECT
    borough,                        -- selects borough colum
    COUNT(*) AS total_requests            -- counts every row and labels that as total_requests 
FROM {{ ref('stg_311_requests') }}            -- ref is a dbt function for referening another model in your project, in this case
                                                 -- it references the staging model, stg_311 requests, using ref builds model in right order
GROUP BY borough                        -- groups all rows by borough value so the count(*) is calculated per borough
ORDER BY total_requests DESC                -- sorts results from highest -> lowest request count, so the busiest borough appears first
