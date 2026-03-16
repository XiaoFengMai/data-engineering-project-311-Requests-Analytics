# this model shows how many complaints were filed for each uinque complaint type in the boroughs 

SELECT                -- initiates query
    borough,                   -- selects borough column
    complaint_type,                -- selects complaint category 
    COUNT(*) AS complaint_count                -- counts every row that has borough and complaints data and labels it complaint_count (*) -> regardless of null values
FROM {{ ref('stg_311_requests') }}        -- pulls data from stg_311_requests staging model using dbt's ref() function
GROUP BY borough, complaint_type               -- creates a row for every unique combinaition of borough and complaint type 
