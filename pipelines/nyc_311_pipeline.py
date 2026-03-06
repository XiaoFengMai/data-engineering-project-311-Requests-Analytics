# this script exxtracts NYC 311 service request data and loads it into bigquery

import dlt
import requests
import pandas as pd

API_URL - "https://data.cityofnewyork.us/resource/erm2-nwe9.json"

@dlt.resource(name="nyc_311_requests", write_disposition="append")
def get_311_requests():
    response = requests.get(API_URL, params={"$limit": 50000})
    data = response.json()
    df = pd.DataFrame(data)
    yield df


@dlt.source
def nyc_311_source():
    return get_311_requests()


def run_pipeline():
    pipeline = dlt.pipeline(
        pipeline_name="nyc_311_pipeline",
        destination="bigquery",
        dataset_name="nyc_311_raw"
    )

    load_info = pipeline.run(nyc_311_source())
    print(load_info)


if __name__ == "__main__":
    run_pipeline()
