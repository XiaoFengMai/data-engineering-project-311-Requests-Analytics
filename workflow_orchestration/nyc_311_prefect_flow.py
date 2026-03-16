# defines a two step pipeline that runs run_ingestion() first and run_dbt() second

# flow makes a function as the main pipeline and task makes a function as an individual step within the pipeline
from prefect import flow, task

# subprocess module allows you to run command lines from within python code
import subprocess


# a prefect decorator that registers the function below it as an individual pipeline task which give sthe function prefect features like logging, retries, and state tracking
@task
def run_ingestion():
    subprocess.run(["python", "ingestion_pipeline/nyc_311_pipeline.py"], check=True)            # runs the ingestion script as a command line process, equivalent to typing in terminal


# once again, registers the function below as a prefect task
@task
def run_dbt():             
    subprocess.run(["dbt", "run"], cwd="data_build_tool/", check=True)                # runs the dbt transformation command


# prefect decorator that registers the function below as the main pipeline flow
@flow        
def nyc_pipeline():               # defines flow function that control the order tasks run in
    ingestion = run_ingestion()            # runs the ingestion task first and stores result in ingestion, prefect uses this result to track when task has completed
    run_dbt(wait_for=[ingestion])                # runs the dbt task but only after ingestion task has completed, ensures dbt does not run on incomplete data

if __name__ == "__main__":             # standard python guard that ensures pipeline only runs when this file is executed
    nyc_pipeline()                            # triggers entire pipeline flow when file is run directly
