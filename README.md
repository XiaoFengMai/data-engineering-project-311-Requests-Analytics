# NYC 311 Urban Operations Analytics Pipeline

## Table of Contents
* [Problem Statement](#problem-statement)
* [Project Objectives](#project-objectives)
* [Architecture Diagram](#architecture-diagram)

* [Technologies Used](#technologies-used)
  
* [Setup Instructions](#setup-instructions)
  * [Prerequisites](#prerequisites)
  * [Cloud Setup GCP](#cloud-setup-gcp)
  * [Infrastructure as Code (Terraform)](#infrastructure-as-code-terraform)
  * [Environment Configuration](#environment-configuration)

* [Data Pipeline](#data-pipeline)
  * [Pipeline Type (Batch Processing)](#pipeline-batch-processing)
  * [Workflow Orchestration (Prefect)](#prefect)
  * [Data Lake (GCS)](#data-lake-gcs)
  * [Data Warehouse (BigQuery)](#data-warehouse-bigquery)
  * [Data Transformation (dbt) ](#data-transformation-dbt)
   
* [Dashboard Visualization](#dashboard-visualization)
  * [Dashboard Overview](#dashboard-overview)
  * [Tile 1: Categorical Distribution](#tile-1-categorical-distribution)
  * [Tile 2: Temporal Trends](#tile-2-temporal-trends)

* [Running the Pipeline](#running-the-pipeline)
  * [Using Docker](#using-docker)
  * [Execute prefect flow](#executing-airflow-dag)
  * [Run dbt Models](#running-dbt-models)
  
* [Sample Output Screenshots](#how-to-set-up-and-run-the-pipeline-with-docker)
* [Final Notes](#final-notes)


## Problem Statement
Large cities like New York generate thousands of service requests daily through the 311 system. These requests cover a wide range of urban issues, including noise complaints, sanitation problems, housing concerns, and infrastructure failures.

As New York City's population grows, so does the volume of 311 requests. This creates several challenges:
- Raw data is large, unstructured, and difficult to analyze
- Manual data processing leads to delays and inconsistencies
- City agencies lack real-time visibility into trends
- Decision-making becomes reactive instead of data-driven
Without an automated system, analysts must manually download, clean, and aggregate data, resulting in inefficient workflows and limited insight generation.
  
The goal is to build a scalable, cloud-based end-to-end data pipeline that transforms raw NYC 311 service request data into clean, analytics-ready datasets and actionable insights.
  

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

Data Engineering
- Python
- dlt (Data Load Tool)
- Prefect (workflow orchestration)
- dbt (data transformation)


Storage & Warehousing
- Google Cloud Storage (GCS)
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
- Google Cloud Account
- Python 3.11
- Docker 
- Terraform 
- dbt
- gcloud CLI configured

### Cloud Setup (GCP)
1. Go to google cloud console and at the top, click project dropdown, new project
2. Fill in project name (name of your choice) and organization (default), create
3. Go to APIs & Services, Library, search and enable BigQuery API and Cloud Storage API
4. install gcloud cli from https://cloud.google.com/sdk/docs/install and authenticate by running "gcloud auth application-default login" in powershell / cmd


### Infrastructure as Code (Terraform)
provision all cloud resources, run in powershell / cmd.
1. Install terraform CLI from https://developer.hashicorp.com/terraform/downloads
2. Open terminal, cd into folder that contains terraform code, cd path\to\project
3. run cd terraform/
4. run terraform init
5. run terraform apply
6. so far, we have a GCS bucket (data lake with raw files), BigQuery dataset (analytics storage), IAM roles (permissions)
 

### Environment Configuration
Create an .env file and add to gitignore
write this out in a terminal:
GCP_PROJECT_ID=your_project_id
BUCKET_NAME=your_bucket_name
DATASET_NAME=your_dataset
replace the 3 variable names with your names


## Data Pipeline
### Pipeline Type (Batch Processing)
This pipeline uses batch processing because:
- NYC 311 data updates periodically
- historical analysis is required
- real-time streaming is not necessary

### Workflow Orchestration (Prefect)
Prefect is used to orchestrate the pipeline:
- schedule batch jobs
- manages task dependencies
- handles retries and failures

### Data Lake (GCS)
- data is extracted using dlt
- source: NYC Open Data API
- output format: parquet

raw data is stored in:
gs://<bucket-name>/raw/YYYY/MM/data.parquet

### Data Warehouse BigQuery
BigQuery is used for analytical queries
Table Design
fact_311_requests
Partitioned by:

DATE(created_date)
Clustered by:
borough, complaint_type

- faster queries
- reduced cost
- optimized for analytics

### Data Transformation (dbt)
dbt transforms raw data into analytics-ready models
Models:
stg_311_requests
- cleans and standardizes raw data
fct_311_requests
- adds derived columns (date, response time)
mart tables
- complaint trends
- borough-level summaries

### Dashboard Visualization
interactive dashboard built with looker studio that enables users to explore NYC 311 trends.

Tile 1 Categorical Distribution
Bar Chart: Complaint Types
- shows the most common complaint type categories
- helps identify major urban issues

Tile 2 Temporal Trends
Line Chart: Complaints over Time
- displays daily complaint volume
- highlights trends and seasonality

## Running the Pipeline
### Using Docker
to build and run the container: (in terminal, cd to project root directory and run...)
docker build -t nyc-311-pipeline
docker run nyc-311-pipeline

### Execute Prefect Flow
install prefect, create deployment
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
