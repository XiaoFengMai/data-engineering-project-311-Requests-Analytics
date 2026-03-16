# this schedule runs the pipeline daily at 2am

# imports the pipeline flow from nyc_311_flow
from nyc_311_flow import nyc_311_flow

# standard python guard that ensures this deployment code only runs when the file is executed directly
if __name__ == "__main__":
    nyc_311_flow.deploy(                    # calls prefect's built-in deploy method, which registers and configures it with prefect server for scheduled execution
        name="nyc-311-daily",                    # names the deployment, this is what is displayed in the prefect UI dashboard
        work_pool_name="default-agent-pool",       # tells prefect which work pool should pick up and execute this flow, agent is a process that listens for scheduled runs and executes them         
        cron="0 2 * * *"                          # sets the schedule using cron syntax, runs everday at 2am
    )
