
# this script extracts NYC 311 service request data and loads it into bigquery

import dlt                    # a python tool for data pipelines that handles schema inference, loading, and warehouse connections 
import requests                        # the requests library used to make HTTP calls to the NYC API
import pandas as pd                            # pandas library converts the raw API response into a structured dataframe

API_URL = "https://data.cityofnewyork.us/resource/erm2-nwe9.json"                    # this stores the nyc open data API endpoint for service requests as a constant 

@dlt.resource(name="nyc_311_requests", write_disposition="append")                   # a dlt decorator that marks the function as a data resource. indicates bigquery table name and appends new data to existing table rather than replacing it, so you build historical data over time
def get_311_requests():                                                    # the function that fetches data
    response = requests.get(API_URL, params={"$limit": 50000})                    # makes an HTTP GET request to the NYC API, pulling 50,000 reccords at a time, limit is a query parameter specific to NYC's Socrata API
    data = response.json()                # parses (extracts raw data and transforms it into structured ready-for-analysis data) the API response from raw json text into a list of dictonaries
    df = pd.DataFrame(data)                    # converts that list of dictionaries into a pandas dataframe, a structured table with rows and columns.
    yield df                                 # instead of return, yield makes this a python generator
                                             # dlt prefers generators because they allow data to be streamed in chunks rather than loaded all at once

@dlt.source                   # a dlt decorator that labels the function below as a source - a collection of one or more resources that belong together.
def nyc_311_source():                    # defines the source function that groups resources
    return get_311_requests()                       # returns the one resource defined above but a source can bundle multiple resources together         


def run_pipeline():                        # defines the main function that configures and runs the pipeline
    pipeline = dlt.pipeline(                        # creates a dlt pipeline object with the settings below
        pipeline_name="nyc_311_pipeline",                        # the name that dlt uses to track pipeline state and store metadata locally
        destination="bigquery",                            # notifies dlt to load data into BigQuery as dlt supports many destinations (snowflake, redshift, duckdb, etc.)
        dataset_name="nyc_311_raw"                   # the BigQuery dataset where the raw table will be created, the raw landing zone is separate from the nyc_311_analytics dataset where dbt writes its transformed models
    )

    load_info = pipeline.run(nyc_311_source())            # executes the pipeline, fetches the data and loads the metadata (what was loaded) gets stored in 'load_info'                 
    print(load_info)                                #prints a summary of the load - how many rows were loaded, any errors, etc.            


if __name__ == "__main__":                # a standard python pattern - this block only runs if you execute this file directly
    run_pipeline()                      # calls the function that starts the pipeline run process
