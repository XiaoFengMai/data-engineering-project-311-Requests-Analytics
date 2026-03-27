import os
import dlt
import requests
from prefect import flow, task
from dotenv import load_dotenv

# Load variables from .env file
load_dotenv()

@task(retries=3, retry_delay_seconds=60)
def fetch_311_data():
    """Fetch raw data from NYC Open Data API"""
    url = "https://data.cityofnewyork.us/resource/erm2-nwe9.json"
    # Filter for last 24 hours or a specific limit for testing
    params = {"$limit": 5000, "$order": "created_date DESC"}
    
    response = requests.get(url, params=params)
    response.raise_for_status()
    return response.json()

@flow(name="NYC 311 Ingestion")
def run_ingestion_pipeline():
    # Fetch values from environment
    project_id = os.getenv("GCP_PROJECT_ID")
    dataset_name = os.getenv("DATASET_NAME", "nyc_311_raw")
    
    data = fetch_311_data()
    
    # Configure dlt to use BigQuery via environment variables
    pipeline = dlt.pipeline(
        pipeline_name="nyc_311_ingestion",
        destination='bigquery',
        dataset_name=dataset_name
    )
    
    load_info = pipeline.run(data, table_name="service_requests")
    print(load_info)

if __name__ == "__main__":
    run_ingestion_pipeline()
