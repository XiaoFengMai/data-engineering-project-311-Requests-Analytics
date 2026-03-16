# this model creates a cleaner dataset

SELECT                            -- starts a transformation query
    unique_key,           

    DATE(created_date) AS created_date,            # converts timestamp into date format, useful for partitioning, aggregation
    DATE(closed_date) AS closed_date,             # same conversion for resolution date

    complaint_type,        
    descriptor,
    borough,            
    agency,                   # these fields pass through unchanged because they already cleaned

    latitude,
    longitude,

    TIMESTAMP_DIFF(closed_date, created_date, HOUR) AS resolution_time_hours        # calculates closed_date - created_date (hours)

    
FROM {{ ref('stg_311_requests') }}        # notifies dbt that this model depends on the stg 311 requests modet so dbt builds stg first
WHERE borough IS NOT NULL                # removes empty rows with missing borough information, location analysis requires valid borough data
