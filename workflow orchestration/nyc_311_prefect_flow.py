# prefect flow
from prefect import flow, task
import subprocess

@task
def run_ingestion():
    subprocess.run(["python", "ingestion_pipeline/nyc_311_pipeline.py"], check=True)

@task
def run_dbt():
    subprocess.run(["dbt", "run"], cwd="data_build_tool/", check=True)

@flow
def nyc_pipeline():
    ingestion = run_ingestion()
    run_dbt(wait_for=[ingestion])

if __name__ == "__main__":
    nyc_pipeline()
