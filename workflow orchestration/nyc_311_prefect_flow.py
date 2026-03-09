from prefect import flow, task
import subprocess

@task
def run_dlt_pipeline():
  subprocess.run(["python", "pipelines/nyc_311_pipeline.py"], check=True)

@flow(name="nyc_311_batch_pipeline")
def nyc_311_flow():

  run_dlt_pipeline()


if __name__ == "__main__":
  nyc_311_flow()
