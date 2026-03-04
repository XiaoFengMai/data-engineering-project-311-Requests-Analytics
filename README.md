# NYC 311 Urban Operations Analytics Pipeline

## table of contents
* [Problem Statement](#problem-statement)
* [Overview](#step-by-step-overview)
* [Technologies used](#technologies)
* [Cloud](#☁️cloud-platform)
  * [Infrastructure as Code](#-🏗-Infrastructure-as-code)
  * [Orchestration](#🔄orchestration)
* [Data Pipeline](#data-pipeline)
  * [Data Ingestion batch](#📥data-ingestion-batch)
  * [Data Lake GCS](#🗄data-lake)
  * [Data Warehouse BigQuery](#🏢data-warehouse)
  * [Transformations](#🧮data-transformation)
* [Dashboard](#📊dashboard-visualization)
* [Instructions for running pipeline](#🐳how-to-set-up-and-run-the-pipeline-with-docker)



## Problem Statement
Large cities like New York receive many service requests through the 311 system. The reasons for these service requests range from noise complaints and sanitation issues to housing and infrastructure problems. If you've lived in New York City, you've likely experienced at least one of these: construction noises early in the morning, missed trash pickup, broken streetlights, traffic congestion, delays in public transportation and more. When something goes wrong, New Yorkers don't just complain, they report it through the city's 311 system.

With more and more people moving to New York City, more complaint reports and raw data of those reports there is to clean. City agencies must monitor complaint volumes, allocate resources efficiently, monitor rising urban issues, and improve response times. Hundreds of 311 service requests are generated daily and we need a system that transforms this public data into clear, decision-ready insights for the people of New York City. The goal is to move from, New Yorkers are complaining more lately about this issue, to, Noise complaints in Manhattan increased 20% over the last quarter, primarily related to construction permits.

Without automation, analysts must manually download and process raw data from the 311 database, leading to delayed reporting, inconsistent metrics, and poor visibility to trends. The goal is to build a reliable end-to-end data pipeline that turns raw NYC 311 service request data into meaningful, analytics-ready insights.



## Step by Step Overview
1. Extract data from NYC service requests 2020-present data set obtained through NYC Open Data: https://data.cityofnewyork.us/Social-Services/311-Service-Requests-from-2020-to-Present/erm2-nwe9/about_data
2.  Store the raw data into a data lake, Google Cloud Storage. The extracted 311 records are written as parquet files and uploaded to a dedicated Google Cloud Storage bucket. Files are organized by ingestion date to support incremental loads, maintain historical snapshots, and ensure scalable, cost-effective storage of raw data in its original form.
3.  Load the datasets into a datawarehouse, BigQuery. Raw files stored in Google Cloud Storage are ingested into BigQuery as structured tables within a designated dataset. Tables are partitioned by created_date and clustered by fields such as borough and complaint_type to optimize query performance and support efficient analytical reporting.
4.  Set up infrastructure using Terraform to ensure that the entire cloud environment can be recreated consistently through infrastructure as a a code.
5. Orchestrate the batch workflow with Prefect to automate the extract, load, transform process from ingestion to transformation.
6. After the data is loaded into BigQuery, use the data build tool (dbt)to clean and aggregate all records into dimension tables optimized for analytical queries. Partitioning and clustering strategies are applied to further improve performance and reflect real-world reporting use cases.
7. The final layer of the pipeline is an interactive dashboard built with Looker Studio, that allows users to explore the most common complaint types across the city, track how complaint volumes change over time, compare service patterns across boroughs, and identify seasonal urban trends.





## Technologies
google cloud platform (GCP) as the primary cloud provider
terraform 
dlt  
prefect flow  
google cloud storage (GCS)  
big query  
data build tool (dbt)  
looker studio  
docker

GIT  
gcloud CLI  
python  
envirionment variables





## ☁️ Cloud Platform
Google Cloud Platform (GCP) as the primary cloud provider

### 🏗 Infrastructure as Code
terraform provisions and manages Google Cloud Platform Resources (Google Cloud Service bucket, BigQuery dataset, IAM roles)

### 🔄 Orchestration
prefect automates and schdules the extract, load, transform workflow.





## Data pipeline

### 📥 Data Ingestion batch
data load tool (dlt) extracts data from the NYC 311 API and loads it into cloud storage and BigQuery, using python as the core scripting language

### 🗄 Data Lake
Google Cloud Storage (GCS), as the data lake, stores raw partitioned parquet files

### 🏢 Data Warehouse
BigQuery, as the data warehouse, is a scalable analytics warehouse partitioned by created_date and clustered by borough and complaint_type

### 🧮 Data Transformation
using the data build tool (dbt) to clean, model, aggregate data into analytics-ready tables
using dbt bigquery adapter to connect dbt to BigQuery




## 📊 Dashboard visualization
looker studio is  an interactive dashboard for exploring NYC 311 trends.

tile 1 - categorical; bar chart showing the count of records per category; ex: top complaint type

tile 2 - temporal; line chart showing trends over time; ex: number of complaints over a time period





## 🐳 How to set up and run the pipeline with docker
uses docker (containerization) to ensure reproducible local development environment.
