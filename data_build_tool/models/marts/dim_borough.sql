-- this query is used to ensure there are no typos for the borough names

SELECT DISTINCT            -- remove duplicates, select only unique values and return it once
    borough                -- select distinct using data from this column
FROM {{ ref('stg_311_requests') }}    -- current model depends on the staging model, which is built first
