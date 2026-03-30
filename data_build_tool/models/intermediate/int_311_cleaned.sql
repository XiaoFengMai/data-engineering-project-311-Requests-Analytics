{{ config(materialized='view') }}

-- This model produces a clean, analytics-ready dataset from the staging layer.
-- Key changes vs raw: timestamps cast to dates, resolution time calculated, nulls filtered.

SELECT
    unique_key,
    DATE(created_date)                                            AS created_date,       -- cast timestamp → date for partitioning & aggregation
    DATE(closed_date)                                             AS closed_date,        -- same conversion for resolution date
    complaint_type,
    descriptor,
    borough,
    agency,                                                                              -- these fields pass through unchanged; already clean from staging
    latitude,
    longitude,
    TIMESTAMP_DIFF(closed_date, created_date, HOUR)               AS resolution_time_hours  -- FIX: was preceded by # comment syntax which BigQuery rejects

FROM {{ ref('stg_311_requests') }}   -- dbt builds stg_311_requests first due to this ref()

WHERE borough IS NOT NULL            -- drop rows with no borough; required for geographic analysis
