# NYC 311 Urban Operations Analytics Pipeline

## table of contents
* [objective](#objective)
* [Problem Statement](#problem-statement)
* [Cloud](#cloud-infrastructure)
  * [Terraform within Google Cloud Platform](#terraform-within-gcp)
  * [Airflow](#set-up-airflow-with-docker)
* [Data Pipeline](#data-pipeline)
  * [Data Ingestion batch DAG](#data-ingestion-DAG)
  * [Data Lake](#google-cloud-storage)
  * [Data Warehouse](#data-warehouse-big-query)
  * [Data Transformatiom](#data-transformation-with-data-build-tool)
* [Dashboard](#dashboard-two-tiles)
* [Instructions for running the pipeline](#set-up-and-run-the-pipeline-with-docker)


google cloud platform (GCP)  
terraform  
dlt  
prefect flow  
google cloud storage (GCS)  
big query  
data build tool (dbt)  
looker studio  
docker


## problem statement
Large cities like New York receive many service requests through the 311 system. These requests range from nosie complaints and sanitation issues to housing and infrastructure problems. If you've lived in New York City, you've likely experienced at least one of these: construction noises early in the morning, missed trash pickup, broken streetlights, traffic congestion, delays in public transportation and more. When something goes wrong, New Yorkers don't just complain, they report it through the city's 311 system.

With more and more people moving to New York City, more complaint reports and raw data of those reports there is to clean. City agencies must monitor complaint volumes, allocate resources efficiently, detect rising urban issues, and improve response times. Hundreds of 311 service requests are generated daily and we need a system that transforms this public data into clear, decision-ready insights. The goal is to move from "New Yorkers are complaining more lately about this issue" to "Noise complaints in Manhattan increased 20% over the last quarter, primarily related to construction permits."


## objective
Without automation, analysts must manually download and process raw data from the 311 database, leading to delayed reporting, inconsistent metrics, and poor visibility to trends. The goal is to build a reliable end-to-end data pipeline that turns raw NYC 311 service request data into meaningful, analytics-ready insights. Using publicly available data from NYC Open Data, the system automatically collects daily complaint records, stores the raw data into a data lake, Google Cloud Storage, and loads the datasets into a datawarehouse, BigQuery.

By starting off the infrastructure using Terraform, we can ensure that the entire cloud environment can be recreated consistently through infrastructure as a a code. Prefect orchestrates the batch workflow, automating the extract, load, transform process from ingestion to transformation. Once the data is loaded into BigQuery, the data build tool (dbt) is then used to clean and aggregate all records into dimension tables optimized for analytical queries. Partitioning and clustering strategies are applied to further improve performance and reflect real-world reporting use cases.

The final layer of the pipeline is an interactive dashboard biuilt with Looker Studio, that allows users to explore the most common complaint types across the city, track how complaint volumes change over time, compare service patterns across boroughs, and identify seasonal urban trends.

