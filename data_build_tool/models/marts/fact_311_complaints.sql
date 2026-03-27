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

-- this model shows how many complaints were filed daily for each unique complaint type in the boroughs 

SELECT                
    DATE(created_date) AS created_date,      -- Adds the date for partitioning
    borough,                                 -- selects borough column
    complaint_type,                          -- selects complaint category 
    COUNT(*) AS complaint_count              -- counts every row 
FROM {{ ref('stg_311_requests') }}        
GROUP BY 
    DATE(created_date), 
    borough, 
    complaint_type
