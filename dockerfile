# Use the official Python 3.11 image as specified in your prerequisites
FROM python:3.11-slim

# Set environment variables to optimize Python execution in Docker
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set the working directory inside the container
WORKDIR /app

# Install system dependencies (git is required for dbt to download external packages/macros)
RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements file first to leverage Docker layer caching
COPY requirements.txt .

# Upgrade pip and install all project dependencies
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy the rest of your project files into the container
COPY . .

# Expose Streamlit's default port so it can be accessed from the host browser
EXPOSE 8501

# Set Streamlit as the default command when the container starts. 
# (Reviewers can still override this to run Prefect or dbt directly)
CMD ["streamlit", "run", "dashboard.py", "--server.port=8501", "--server.address=0.0.0.0"]
