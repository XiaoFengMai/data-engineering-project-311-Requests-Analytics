# NYC 311 Urban Operations Analytics Pipeline

## Table of Contents
* [Problem Statement](#problem-statement)
* [Project Objectives](#project-objectives)
* [Architecture Diagram](#architecture-diagram)

* [Technologies Used](#technologies-used)
  
* [Setup Instructions](#setup-instructions)
  * [Prerequisites](#prerequisites)
  * [Cloud Setup GCP](#cloud-setup-gcp)
  * [Infrastructure as Code Terraform](#infrastructure-as-code-terraform)

* [Data Pipeline](#data-pipeline)
  * [Pipeline Type Batch Processing](#pipeline-type-batch-processing)
  * [Workflow Orchestration Prefect](#workflow-orchestration-prefect)
  * [Data Lake GCS](#data-lake-gcs)
  * [Data Warehouse BigQuery](#data-warehouse-bigquery)
  * [Data Transformation dbt](#data-transformation-dbt)
   
* [Dashboard Visualization](#dashboard-visualization)
  * [Dashboard Overview](#dashboard-overview)
  * [Tile 1: Categorical Distribution](#tile-1-categorical-distribution)
  * [Tile 2: Temporal Trends](#tile-2-temporal-trends)

* [Running the Pipeline](#running-the-pipeline)
  * [Clone the Repository](#Clone-the-Repository)
  * [Configure Environment Variables](#configure-environment-variables)
  * [Using Docker](#using-docker)
  * [Execute prefect flow](#execute-prefect-flow)
  * [Run dbt Models](#run-dbt-models)
  
* [Sample Output Screenshots](#sample-output-screenshots)
* [Final Notes](#final-notes)


## Problem Statement
Large cities like New York generate thousands of service requests daily through the 311 system. These requests cover a wide range of urban issues, including noise complaints, sanitation problems, housing concerns, and infrastructure failures.

As New York City's population grows, so does the volume of 311 requests. This creates several challenges:
- Raw data is large, unstructured, and difficult to analyze
- Manual data processing leads to delays and inconsistencies
- City agencies lack real-time visibility into trends
- Decision-making becomes reactive instead of data-driven
Without an automated system, analysts must manually download, clean, and aggregate data, resulting in inefficient workflows and limited insight generation.
  
The goal is to build a scalable, cloud-based end-to-end data pipeline that transforms raw NYC 311 service request data into clean, analytics-ready datasets and actionable insights that can be used to analyze trends over time.
  

## Project Objectives 
Build a data pipeline that
1. Extract Data
Pull NYC 311 service request data (2020–present) from NYC Open Data.
2. Provision Infrastructure (IaC)
Use Terraform to create and manage all cloud resources.
3. Build a Data Lake
Store raw data in Google Cloud Storage (GCS) in partitioned parquet format.
4. Load Data into a Data Warehouse
Ingest structured data into BigQuery for analytical querying.
5. Orchestrate the Pipeline
Use Prefect to automate the batch ETL workflow.
6. Transform Data
Use dbt to clean, model, and aggregate data into analytics-ready tables.
7. Visualize Insights
Build an interactive dashboard to explore complaint trends across time and categories.



## Architecture Diagram
NYC Open Data API
        ↓
Prefect (Orchestration)
        ↓
GCS (Data Lake)
        ↓
BigQuery (Data Warehouse)
        ↓
dbt (Transformations)
        ↓
Looker Studio (Dashboard)

<img width="698" height="1516" alt="mermaid-diagram" src="https://github.com/user-attachments/assets/3c8146a3-87c2-4966-8460-7b68785c0b4f" />


## Technologies Used
Cloud & Infrastructure
- Google Cloud Platform (GCP)
- Terraform (Infrastructure as Code)

Orchestration
- prefect

Data Ingestion
- Python
- dlt (Data Load Tool)

Data Transformation
- dbt (data build tool)

Storage
- Google Cloud Storage (GCS)

Data Warehouse
- BigQuery

Visualization
- Looker Studio

DevOps & Environment
- Docker
- Git
- gcloud CLI
- Environment Variables

## Setup Instructions
### Prerequisites
ensure that the following are installed and configured before proceeding
- Python 3.11 https://www.python.org/downloads/
- Docker Latest version https://docs.docker.com/get-docker/
- Terraform Latest version https://developer.hashicorp.com/terraform/downloads
- dbt version 1.7+ https://docs.getdbt.com/docs/core/installation
- Git Latest version https://git-scm.com/downloads
- gcloud CLI Latest version https://cloud.google.com/sdk/docs/install
- Google Cloud Account with billing enabled
  - see google cloud setup below

### Cloud Setup GCP
1. Go to google cloud console and at the top, click project dropdown, new project
2. Fill in project name (name of your choice) and organization (default), create
3. Go to APIs & Services, Library, search and enable BigQuery API and Cloud Storage API
4. authenticate gcloud CLI locally by running "gcloud auth application-default login" in powershell / cmd
5. set active project by running "gcloud config set project YOUR_PROJECT_ID"


### Infrastructure as Code Terraform
provisions GCS bucket (data lake), BigQuery dataset, and IAM roles automatically run in powershell / cmd.
1. Install terraform CLI from https://developer.hashicorp.com/terraform/downloads
2. Open terminal, cd into folder that contains terraform code, cd path\to\project
3. run cd terraform/ (navigate to terraform directory)
4. run terraform init (initialize terraform, downloads required providers)
5. run terraform plan (preview resources that will be created)
6. run terraform apply (create all cloud resources)
7. when prompted, type yes to confirm.
8. after running the above, we have a GCS bucket (data lake with raw files), BigQuery dataset (analytics storage), IAM roles (permissions)
 

## Data Pipeline
### Pipeline Type Batch Processing
This pipeline uses batch processing because:
- NYC 311 data updates periodically
- historical analysis is required (data dates back to 2020)
- real-time streaming is not necessary for this use case

### Workflow Orchestration Prefect
Prefect orchestrates the pipeline by:
- scheduling batch jobs
- managing task dependencies across extract, load, and transform steps
- handling retries and failure notifications automatically

### Data Lake GCS
- data is extracted using dlt (data load tool)
- source: NYC Open Data API
- output format: parquet

raw data is stored in:
gs://<bucket-name>/raw/YYYY/MM/data.parquet

### Data Warehouse BigQuery
BigQuery is used for analytical queries
Table Design - fact_311_requests:
to reduce data scanned for time-range queries:
Partitioned by:
DATE(created_date) 

to speed up filtered aggregations by location and category
Clustered by:
borough, complaint_type

this is done for:
- faster queries
- reduced cost
- optimized for analytics

### Data Transformation dbt
dbt transforms raw BigQuery data into analytics-ready models
Models:
stg_311_requests
- cleans and standardizes raw data (types, nulls, naming)
fct_311_requests
- adds derived columns (parsed date parts, response time in hours)
mart tables
- mart_complaint_trends: aggregated complaint coutns by type and date 
- mart_borough_summary: borough-level summaries for geographic analysis

## Dashboard Visualization
### Dashboard Overview
an interactive dashboard built with looker studio that enables users to explore NYC 311 trends.

<img width="961" height="589" alt="image" src="https://github.com/user-attachments/assets/f1a53d34-11d3-4362-9d3c-21452a43186a" />
<img width="933" height="523" alt="image" src="https://github.com/user-attachments/assets/c0369fa1-4e0e-41e7-934a-d9ed5526408c" />



### Tile 1 Categorical Distribution
Bar Chart: Top Complaint Types
- shows the most common 311 complaint type categories 
- helps identify high prority urban issues

### Tile 2 Temporal Trends
Line Chart: Daily Complaint Volume over Time
- displays daily complaint counts from 2020 to present
- highlights seasonal patterns, spikes, trends and seasonality

## Running the Pipeline
Follow these steps in order to reproduce the full pipeline from scratch
### Clone the Repository
git clone https://github.com/YOUR_USERNAME/nyc-311-pipeline.git
cd nyc-311-pipeline

### Create Environment Varibles
1. The .env file is listed in .gitignore and will not be committed to version control. never share credentials
2. A reference file .env.example is included in the repository with placeholder values
3. Copy the example environment file: cp .env.example .env
4. Open .env and fill in your values:
5. GCP_PROJECT_ID=your_project_id        # e.g. nyc-311-analytics-123456
BUCKET_NAME=your_bucket_name          # e.g. nyc-311-raw-data
DATASET_NAME=your_dataset_name        # e.g. nyc_311_warehouse
NO JSON key required. Application default credentials via gcloud is sufficient for local development

### Using Docker
Docker packages all dependencies so no manual python environment setup is needed. This project uses authentication default credentials (ADC) so you mount your local gcloud credentials into container at runtime
to build and run the container with environment variables and ADC credentials mounted: (in powershell, cd to project root directory and run...)
docker build -t nyc-311-pipeline .
docker run --env-file .env `
  -v "$env:APPDATA\gcloud:/root/.config/gcloud:ro" `
  nyc-311-pipeline

### Execute Prefect Flow
install prefect, create deployment
pip install prefect
prefect server start
deployment yaml
in terminal, cd to project root directory...
prefect deployment run <flow-name>


### Run dbt models
cd dbt/
dbt run (builds tables/models in BigQuery)
dbt test (validates test quality)

## Sample Output Screenshots
<img width="1536" height="1024" alt="NYC 311 analytics png" src="https://github.com/user-attachments/assets/84f4609a-680c-4bf5-b538-79d4db51d4f1" />


## Final Notes
This project demonstrates:
- End-to-end data engineering workflow
- Cloud-native architecture
- Infrastructure as Code
- Batch data processing
- Data modeling and transformation
- Business intelligence visualization
