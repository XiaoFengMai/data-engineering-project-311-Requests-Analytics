{{
    config(
        materialized='table',
        partition_by={
            "field": "created_date",
            "data_type": "date",
            "granularity": "day"
        },
        cluster_by=['borough', 'complaint_type']
    )
}}

-- Core fact table: one row per (date, borough, complaint_type) combination.
-- Partitioned by created_date for fast time-range queries.
-- Clustered by borough + complaint_type to speed up filtered aggregations.

SELECT
    DATE(created_date)  AS created_date,
    borough,
    complaint_type,
    COUNT(*)            AS complaint_count

FROM {{ ref('stg_311_requests') }}

WHERE
    created_date   IS NOT NULL
    AND borough    IS NOT NULL
    AND complaint_type IS NOT NULL

GROUP BY
    DATE(created_date),
    borough,
    complaint_type
