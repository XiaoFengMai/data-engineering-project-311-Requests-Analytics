{{ config(materialized='table') }}

-- Dimension table: all distinct valid borough names.
-- Used for reference joins and to catch spelling variants in the source data.

SELECT DISTINCT
    borough
FROM {{ ref('stg_311_requests') }}
WHERE borough IS NOT NULL
ORDER BY borough
