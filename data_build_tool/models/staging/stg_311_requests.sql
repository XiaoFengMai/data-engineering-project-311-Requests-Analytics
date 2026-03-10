
SELECT
    unique_key,            # uniquely identify 311 requests; prevent duplicates
    created_date,            # trend analysis, partioning
    closed_date,            # compute resolution time
    complaint_type,            # categorize complaints
    descriptor,            # more detailed complaint description
    borough,            # request location: manhattan, brooklyn, queens, staten island, bronx
    agency,            # which city department
    status,            
    latitude,           # mapping visualizations
    longitude
  
FROM `YOUR_GCP_PROJECT_ID.nyc_311_raw.service_requests`        # must edit GCP project id here
                                                                # selects the raw dataset that the pipeline loaded earlier
