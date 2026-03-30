FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# System deps: git is required by dbt to download packages (dbt deps)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies first (separate layer = faster rebuilds)
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . .

# Download dbt packages (dbt_utils etc.) defined in packages.yml
# This runs at build time so the container is self-contained
RUN dbt deps --profiles-dir . || true

# Expose Streamlit port
EXPOSE 8501

# Default: run the Streamlit dashboard.
# Override at runtime to run other pipeline steps:
#
#   dbt run:
#     docker run --env-file .env -v ~/.config/gcloud:/root/.config/gcloud:ro \
#       nyc-311-pipeline dbt run --profiles-dir .
#
#   Prefect flow:
#     docker run --env-file .env -v ~/.config/gcloud:/root/.config/gcloud:ro \
#       nyc-311-pipeline python workflow_orchestration/nyc_311_prefect_flow.py
#
#   Ingestion only:
#     docker run --env-file .env -v ~/.config/gcloud:/root/.config/gcloud:ro \
#       nyc-311-pipeline python ingestion_pipeline/nyc_311_pipeline.py

CMD ["streamlit", "run", "dashboard.py", "--server.port=8501", "--server.address=0.0.0.0"]
