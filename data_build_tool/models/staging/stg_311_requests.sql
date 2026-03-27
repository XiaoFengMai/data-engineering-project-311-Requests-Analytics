{{ config(materialized='view') }}

SELECT
    -- Identifiers
    CAST(unique_key AS STRING) AS unique_key,        -- uniquely identify 311 requests; prevent duplicates
    
    -- Timestamps
    CAST(created_date AS TIMESTAMP) AS created_date, -- trend analysis, partitioning
    CAST(closed_date AS TIMESTAMP) AS closed_date,   -- compute resolution time
    
    -- Categorical Data
    CAST(complaint_type AS STRING) AS complaint_type, -- categorize complaints
    CAST(descriptor AS STRING) AS descriptor,         -- more detailed complaint description
    CAST(agency AS STRING) AS agency,                 -- which city department
    CAST(status AS STRING) AS status,            
    
    -- Location Data
    CAST(borough AS STRING) AS borough,               -- request location
    CAST(latitude AS FLOAT64) AS latitude,            -- mapping visualizations
    CAST(longitude AS FLOAT64) AS longitude
  
-- Uses dbt source macro instead of hardcoded project IDs
FROM {{ source('staging', 'service_requests') }} 

-- Good practice: filter out completely invalid rows early
WHERE unique_key IS NOT NULL
