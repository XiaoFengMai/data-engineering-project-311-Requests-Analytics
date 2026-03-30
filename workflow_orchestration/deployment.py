from nyc_311_prefect_flow import run_ingestion_pipeline  # FIX: was 'from nyc_311_flow import nyc_311_flow' — file is nyc_311_prefect_flow.py and the flow function is run_ingestion_pipeline

if __name__ == "__main__":
    run_ingestion_pipeline.deploy(
        name="nyc-311-daily",
        work_pool_name="default-agent-pool",
        cron="0 2 * * *"               # runs every day at 2 AM UTC
    )
