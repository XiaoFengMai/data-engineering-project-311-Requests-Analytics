# NYC 311 Urban Operations Analytics Pipeline

## Table of Contents
* [Problem Statement](#problem-statement)
* [Project Objectives](#project-objectives)
* [Architecture Diagram](#architecture-diagram)

* [Technologies Used](#technologies-used)
  
* [Setup Instructions](#setup-instructions)
  * [Prerequisites](#prerequisites)
  * [Clone the Repository](#clone-the-repository)
  * [Configure Environment Variables](#configure-environment-variables)
  * [Cloud Setup GCP](#cloud-setup-gcp)
  * [Infrastructure as Code Terraform](#infrastructure-as-code-terraform)

* [Runnning the Pipeline](#running-the-pipeline)
  * [Option A Docker](#option-A-docker)
  * [Option B Local Python](#option-b-local-python)
  * [Run Ingestion Flow Prefect](#run-ingestion-flow-prefect)
  * [Run dbt transformations](#run-dbt-transformations)
  * [View the dashboard](#view-the-dashboard)


* [Data Pipeline Detail](#data-pipeline-detail)
  * [Ingestion](#ingestion)
  * [Orchestration](#orchestration)
  * [Data Warehouse Design](#data-warehouse-design)
  * [dbt tranformations](#dbt-transformations)

  
* [Dashboard](#dashboard)
* [Final Notes](#final-notes)

---
  
## Problem Statement
New York City's 311 system receives hundreds of thousands of service requests every month covering noise complaints, sanitation issues, housing concerns, and infrastructure failures. Without an automated pipeline, analysts must manually download, clean, and aggregate this data — resulting in slow, error-prone workflows and limited visibility into trends.
 
This project builds a fully automated, cloud-native end-to-end data pipeline that:
- Ingests raw 311 data from the NYC Open Data API
- Stores it in a partitioned, cost-efficient data warehouse
- Transforms it into analytics-ready models using dbt
- Exposes insights through an interactive Looker Studio dashboard (with a local Streamlit fallback)


--- 

## Project Objectives 
Build a data pipeline that
1. **Extract** — Pull NYC 311 service request data (2020–present) from NYC Open Data
2. **Provision** — Use Terraform to manage all GCP infrastructure as code
3. **Load** — Ingest structured records into BigQuery via dlt
4. **Orchestrate** — Schedule and monitor the ETL workflow with Prefect
5. **Transform** — Clean, model, and aggregate data with dbt
6. **Visualize** — Build an interactive dashboard on Looker Studio (+ Streamlit locally)


---  



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
| Category | Tool |
|---|---|
| Cloud platform | Google Cloud Platform (GCP) |
| Infrastructure as Code | Terraform |
| Orchestration | Prefect 2 |
| Data ingestion | Python, dlt (Data Load Tool) |
| Data warehouse | BigQuery |
| Transformation | dbt (dbt-core + dbt-bigquery) |
| Visualisation | Looker Studio (primary), Streamlit (local) |
| Containerisation | Docker |
| Version control | Git / GitHub |
| Authentication | gcloud Application Default Credentials (ADC) |
 
---

  
## Setup Instructions
### Prerequisites
Install and configure the following before proceeding:
 
| Tool | Version | Link |
|---|---|---|
| Python | 3.11+ | https://www.python.org/downloads/ |
| Docker | Latest | https://docs.docker.com/get-docker/ |
| Terraform | Latest | https://developer.hashicorp.com/terraform/downloads |
| gcloud CLI | Latest | https://cloud.google.com/sdk/docs/install |
| Git | Latest | https://git-scm.com/downloads |
 
You also need a **Google Cloud account with billing enabled**.

---  

### Clone the Repository
```bash
git clone https://github.com/YOUR_USERNAME/nyc-311-pipeline.git
cd nyc-311-pipeline
```


### Configure Environment variables

---

The `.env` file holds your GCP credentials. It is listed in `.gitignore` and will never be committed.
 
```bash
# Copy the template
cp .env.example .env
```
Open `.env` and fill in your values:
 
```bash
GCP_PROJECT_ID="your-gcp-project-id"        # e.g. nyc-311-analytics-123456
GCP_REGION="us-central1"
BUCKET_NAME="nyc-311-raw-your-unique-suffix" # must be globally unique
DATASET_NAME="nyc_311_analytics"
```
 
> **Authentication note:** This project uses **Application Default Credentials (ADC)** — no JSON service account key is needed. After installing the gcloud CLI, run:
> ```bash
> gcloud auth application-default login
> ```
---


### Cloud Setup (GCP)
 
1. Go to the [Google Cloud Console](https://console.cloud.google.com/) and create a new project
2. Enable the following APIs under **APIs & Services → Library**:
   - BigQuery API
   - Cloud Storage API
3. Set your active project:
   ```bash
   gcloud config set project YOUR_PROJECT_ID
   ```
 
---

### Infrastructure as Code Terraform
Terraform creates the GCS bucket (data lake) and BigQuery dataset automatically.
 
```bash
# Navigate to the terraform directory
cd terraform/
 
# Fill in your values
cp terraform.tfvars terraform.tfvars   # already exists; open it and edit
 
# Initialise Terraform (downloads the Google provider)
terraform init
 
# Preview what will be created
terraform plan
 
# Create the resources (type 'yes' when prompted)
terraform apply
```
 
After a successful apply you will see:
```
bucket_name      = "nyc-311-raw-your-suffix"
bigquery_dataset = "nyc_311_analytics"
```
 
Return to the project root:
```bash
cd ..
```
 

---  


## Running the Pipeline
### Option A Docker
(recommended)

Docker packages all dependencies so no local Python environment is needed.
 
```bash
# Build the image
docker build -t nyc-311-pipeline .
 
# Run the Streamlit dashboard
docker run -p 8501:8501 \
  --env-file .env \
  -v "$HOME/.config/gcloud:/root/.config/gcloud:ro" \
  nyc-311-pipeline
 
# Run the Prefect ingestion flow
docker run \
  --env-file .env \
  -v "$HOME/.config/gcloud:/root/.config/gcloud:ro" \
  nyc-311-pipeline \
  python workflow_orchestration/nyc_311_prefect_flow.py
 
# Run dbt transformations
docker run \
  --env-file .env \
  -v "$HOME/.config/gcloud:/root/.config/gcloud:ro" \
  nyc-311-pipeline \
  dbt run --profiles-dir .
```
 
**Windows PowerShell** — replace `$HOME/.config/gcloud` with `$env:APPDATA\gcloud`:
```powershell
docker run -p 8501:8501 --env-file .env `
  -v "$env:APPDATA\gcloud:/root/.config/gcloud:ro" `
  nyc-311-pipeline
```
 
---

### Option B Local Python
Docker packages all dependencies so no local Python environment is needed.
 
```bash
# Build the image
docker build -t nyc-311-pipeline .
 
# Run the Streamlit dashboard
docker run -p 8501:8501 \
  --env-file .env \
  -v "$HOME/.config/gcloud:/root/.config/gcloud:ro" \
  nyc-311-pipeline
 
# Run the Prefect ingestion flow
docker run \
  --env-file .env \
  -v "$HOME/.config/gcloud:/root/.config/gcloud:ro" \
  nyc-311-pipeline \
  python workflow_orchestration/nyc_311_prefect_flow.py
 
# Run dbt transformations
docker run \
  --env-file .env \
  -v "$HOME/.config/gcloud:/root/.config/gcloud:ro" \
  nyc-311-pipeline \
  dbt run --profiles-dir .
```
 
**Windows PowerShell** — replace `$HOME/.config/gcloud` with `$env:APPDATA\gcloud`:
```powershell
docker run -p 8501:8501 --env-file .env `
  -v "$env:APPDATA\gcloud:/root/.config/gcloud:ro" `
  nyc-311-pipeline
```
 
---  

  

### Run Ingestion Flow Prefect
This fetches records from the NYC Open Data API and loads them into BigQuery.
 
**Run once (no scheduling):**
```bash
python workflow_orchestration/nyc_311_prefect_flow.py
```
 
**With Prefect UI and daily scheduling:**
```bash
# Start the Prefect server (in a separate terminal)
prefect server start
 
# Register the daily deployment
python workflow_orchestration/deployment.py
 
# Trigger a manual run from the UI or CLI
prefect deployment run "NYC 311 Ingestion/nyc-311-daily"
```
 
---
  

### Run dbt transformations
```bash
# Install dbt packages (first time only)
dbt deps --profiles-dir .
 
# Build all models (staging → intermediate → marts)
dbt run --profiles-dir .
 
# Run data quality tests
dbt test --profiles-dir .
 
# Generate and view documentation
dbt docs generate --profiles-dir .
dbt docs serve --profiles-dir .
```
 
After `dbt run` you will have the following tables/views in BigQuery:
 
| Name | Type | Layer |
|---|---|---|
| `stg_311_requests` | view | staging |
| `int_311_cleaned` | view | intermediate |
| `fact_311_complaints` | table (partitioned) | marts |
| `complaints_by_type` | table | marts |
| `complaints_by_borough` | table | marts |
| `complaints_over_time` | table | marts |
| `dim_borough` | table | marts |
 
---
 
  
  
### View the dashboard
 
**Streamlit (local):**
```bash
streamlit run dashboard.py
```
Open http://localhost:8501 in your browser.
 
The dashboard loads data in this priority order:
1. Live BigQuery query (if `GCP_PROJECT_ID` is set and ADC is configured)
2. Local CSV export at `data/fact_311_complaints.csv`
3. Generated sample data (fallback — always works for reviewers)
 
**Looker Studio (primary dashboard):**
 
The live interactive dashboard is hosted on Looker Studio and connects directly to the `fact_311_complaints` BigQuery table.
 
<img width="961" alt="Looker Studio dashboard" src="https://github.com/user-attachments/assets/f1a53d34-11d3-4362-9d3c-21452a43186a" />
 
---

   

## Data Pipeline Detail

### Ingestion

- **Source:** NYC Open Data API endpoint `erm2-nwe9` (311 Service Requests from 2010 to Present)
- **Tool:** dlt with the `bigquery` destination
- **Write mode:** `append` — new records are added on each run; historical data is preserved
- **Batch size:** 50,000 rows per API call (Socrata API limit)
- **Schema inference:** dlt automatically detects column types from the JSON response
 
---

## Data Warehouse Design
Prefect manages the pipeline schedule and retry logic:
 
The `fact_311_complaints` table is optimised for analytical queries:
 
- **Partitioned by** `DATE(created_date)` — BigQuery scans only the date partitions touched by a query, significantly reducing cost for time-range filters
- **Clustered by** `borough, complaint_type` — speeds up filtered aggregations used by every dashboard chart

--- 

### dbt Transformations
 
```
stg_311_requests          (view)   type casts, null filters, name standardisation
    └── int_311_cleaned   (view)   DATE casts, resolution_time_hours, null borough removed
            ├── fact_311_complaints      (table) daily × borough × type counts
            ├── complaints_by_type       (table) total requests per complaint type
            ├── complaints_by_borough    (table) total requests per borough
            ├── complaints_over_time     (table) daily total request counts
            └── dim_borough              (table) distinct valid borough names
```

Data quality tests (`dbt test`):
- `unique_key` — unique and not null in staging and intermediate
- `created_date`, `borough`, `complaint_type` — not null in the fact table
- `request_date` — unique and not null in `complaints_over_time`
- `borough` — unique and not null in `dim_borough`

 
---

## Dashboard
The Streamlit dashboard includes:
 
- **KPI row** — total requests, distinct complaint types, boroughs covered (all filtered live)
- **Sidebar filters** — filter by borough, complaint type, and date range
- **Top complaint types** — horizontal bar chart of the 15 most common categories
- **Daily complaint volume** — time-series line chart showing request trends
- **Requests by borough** — donut/pie chart of geographic distribution
- **Borough × type heatmap** — cross-tabulation of the 8 most common types across boroughs
 
<img width="961" alt="Dashboard tile 1" src="https://github.com/user-attachments/assets/f1a53d34-11d3-4362-9d3c-21452a43186a" />
<img width="933" alt="Dashboard tile 2" src="https://github.com/user-attachments/assets/c0369fa1-4e0e-41e7-934a-d9ed5526408c" />

---



## Final Notes
This project demonstrates:
- End-to-end data engineering workflow
- Cloud-native architecture
- Infrastructure as Code
- Batch data processing
- Data modeling and transformation
- Business intelligence visualization




