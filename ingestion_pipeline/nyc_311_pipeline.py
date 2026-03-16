
# this script extracts NYC 311 service request data and loads it into bigquery

# dlt for data pipelines that handles schema inference, loading, and warehouse connections, requests library used to make HTTP calls to the NYC API, pandas library converts the raw API response into a structured dataframe
import dlt                    
import requests                     
import pandas as pd                           

# this stores the nyc open data API endpoint for service requests as a constant
API_URL = "https://data.cityofnewyork.us/resource/erm2-nwe9.json"                     

#  a dlt decorator that marks the function as a data resource. indicates bigquery table name and appends new data to existing table rather than replacing it, so you build historical data over time
@dlt.resource(name="nyc_311_requests", write_disposition="append")                 

# function that fetches data, makes an HTTP GET request to the NYC API, limit is a query parameter specific to NYC's Socrata API, parses the API response from raw json text into a list of dictonaries, converts list of dictionaries into a pandas dataframe,
def get_311_requests():                                                    
    response = requests.get(API_URL, params={"$limit": 50000})                    
    data = response.json()                
    df = pd.DataFrame(data)                    
    yield df                                 
# instead of return, yield makes this a python generator, dlt prefers generators because they allow data to be streamed in chunks rather than loaded all at once
                                              

# a dlt decorator that labels the function below as a source - a collection of one or more resources that belong together, defines the source function that groups resources, returns the one resource defined above   
@dlt.source                   
def nyc_311_source():                   
    return get_311_requests()                       

# defines the main function that configures and runs the pipeline, creates a dlt pipeline object with the settings below, load data into bigquery
def run_pipeline():                        
    pipeline = dlt.pipeline(                         
        pipeline_name="nyc_311_pipeline",                        
        destination="bigquery",                            
        dataset_name="nyc_311_raw"                 
    )

    # executes the pipeline, fetches the data and loads the metadata (what was loaded) gets stored in 'load_info'
    load_info = pipeline.run(nyc_311_source())
    #prints a summary of the load - how many rows were loaded, any errors, etc.
    print(load_info)                                            



# a standard python pattern - this block only runs if you execute this file directly, calls the function that starts the pipeline run process
if __name__ == "__main__":                
    run_pipeline()                      
