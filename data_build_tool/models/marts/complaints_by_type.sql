# this query filters complaint types displayed within looker dashboard charts
    
SELECT                    # starts aggregation query
    complaint_type,                   # groups data by complaint type
    COUNT(*) AS total_requests            # counts number of service requests
FROM {{ ref('int_311_cleaned') }}           # uses cleaned intermdiate dataset     
GROUP BY complaint_type                # groups records by complaint category
ORDER BY total_requests DESC                # sorts complaint results from most common -> least common
                                            # ideal for dashboard bar charts
