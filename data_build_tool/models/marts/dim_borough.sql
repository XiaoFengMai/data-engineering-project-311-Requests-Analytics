SELECT DISTINCT
    borough
FROM {{ ref('stg_311_requests') }}
