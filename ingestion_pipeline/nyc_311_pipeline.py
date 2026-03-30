"""
nyc_311_pipeline.py
-------------------
Standalone dlt ingestion script for the NYC 311 service requests pipeline.

Usage (run directly, outside Prefect):
    python ingestion_pipeline/nyc_311_pipeline.py

The Prefect-orchestrated version lives in:
    workflow_orchestration/nyc_311_prefect_flow.py
"""

import dlt
import requests
import pandas as pd
from dotenv import load_dotenv
import os

load_dotenv()

API_URL = "https://data.cityofnewyork.us/resource/erm2-nwe9.json"
LIMIT   = 50000


@dlt.resource(name="nyc_311_requests", write_disposition="append")
def get_311_requests(limit: int = LIMIT):
    """
    dlt resource: fetches records from the NYC Open Data API and yields a
    DataFrame. dlt streams it into BigQuery in chunks.
    """
    response = requests.get(
        API_URL,
        params={"$limit": limit, "$order": "created_date DESC"},
        timeout=60,
    )
    response.raise_for_status()

    data = response.json()
    print(f"Fetched {len(data)} records from NYC Open Data API")

    df = pd.DataFrame(data)
    yield df


@dlt.source
def nyc_311_source(limit: int = LIMIT):
    """dlt source grouping all NYC 311 resources."""
    return get_311_requests(limit=limit)


def run_pipeline(limit: int = LIMIT):
    """Configure and execute the dlt pipeline."""
    dataset_name = os.getenv("DATASET_NAME", "nyc_311_analytics")

    pipeline = dlt.pipeline(
        pipeline_name="nyc_311_pipeline",
        destination="bigquery",
        dataset_name=dataset_name,
    )

    load_info = pipeline.run(nyc_311_source(limit=limit))
    print(load_info)
    return load_info


if __name__ == "__main__":
    run_pipeline()
