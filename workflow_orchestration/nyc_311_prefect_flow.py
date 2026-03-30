import os
import dlt
import requests
from prefect import flow, task
from dotenv import load_dotenv

load_dotenv()

@task(retries=3, retry_delay_seconds=60, log_prints=True)
def fetch_311_data(limit: int = 5000):
    """Fetch raw records from the NYC Open Data 311 API."""
    url = "https://data.cityofnewyork.us/resource/erm2-nwe9.json"
    params = {"$limit": limit, "$order": "created_date DESC"}

    response = requests.get(url, params=params, timeout=30)
    response.raise_for_status()

    records = response.json()
    print(f"Fetched {len(records)} records from NYC Open Data API")
    return records


@flow(name="NYC 311 Ingestion", log_prints=True)
def run_ingestion_pipeline(limit: int = 5000):
    """
    End-to-end ingestion flow:
      1. Fetch records from NYC Open Data API
      2. Load them into BigQuery via dlt (append mode)
    """
    project_id  = os.getenv("GCP_PROJECT_ID")
    dataset_name = os.getenv("DATASET_NAME", "nyc_311_analytics")  # reads from .env

    if not project_id:
        raise ValueError("GCP_PROJECT_ID is not set. Check your .env file.")

    data = fetch_311_data(limit=limit)

    pipeline = dlt.pipeline(
        pipeline_name="nyc_311_ingestion",
        destination="bigquery",
        dataset_name=dataset_name,
    )

    load_info = pipeline.run(data, table_name="service_requests")
    print(load_info)
    return load_info


if __name__ == "__main__":
    run_ingestion_pipeline()
