"""
dashboard.py
------------
Streamlit dashboard for the NYC 311 Service Requests Analytics Pipeline.

Data loading priority:
  1. Live BigQuery query  (if GCP_PROJECT_ID + DATASET_NAME are set in .env)
  2. Local CSV export     (data/fact_311_complaints.csv)
  3. Generated sample data (so the app never crashes for reviewers)

Run locally:
    streamlit run dashboard.py

Run via Docker:
    docker run -p 8501:8501 --env-file .env \\
      -v "$HOME/.config/gcloud:/root/.config/gcloud:ro" \\
      nyc-311-pipeline
"""

import os
import streamlit as st
import pandas as pd
import plotly.express as px
import numpy as np
from dotenv import load_dotenv

load_dotenv()

# ── Page config ───────────────────────────────────────────────────────────────
st.set_page_config(
    page_title="NYC 311 Operations Dashboard",
    page_icon="🗽",
    layout="wide",
)

st.title("🗽 NYC 311 Service Requests Dashboard")
st.markdown(
    "Interactive dashboard powered by the dbt-transformed "
    "`fact_311_complaints` table in BigQuery."
)

# ── Data loading ──────────────────────────────────────────────────────────────
@st.cache_data(ttl=3600)
def load_from_bigquery() -> pd.DataFrame | None:
    """
    Attempt to query BigQuery directly using Application Default Credentials.
    Returns None if credentials or env vars are not available.
    """
    project_id   = os.getenv("GCP_PROJECT_ID")
    dataset_name = os.getenv("DATASET_NAME", "nyc_311_analytics")

    if not project_id:
        return None

    try:
        from google.cloud import bigquery  # only import if we need it

        client = bigquery.Client(project=project_id)
        query  = f"""
            SELECT
                created_date,
                borough,
                complaint_type,
                complaint_count
            FROM `{project_id}.{dataset_name}.marts.fact_311_complaints`
            ORDER BY created_date DESC
            LIMIT 200000
        """
        df = client.query(query).to_dataframe()
        df["created_date"] = pd.to_datetime(df["created_date"])
        return df

    except Exception:
        return None


@st.cache_data
def load_from_csv() -> pd.DataFrame | None:
    """Load from a local CSV export of the fact table."""
    try:
        df = pd.read_csv("data/fact_311_complaints.csv")
        df["created_date"] = pd.to_datetime(df["created_date"])
        return df
    except FileNotFoundError:
        return None


@st.cache_data
def generate_sample_data() -> pd.DataFrame:
    """
    Fallback: generate synthetic data that matches the fact_311_complaints schema.
    Lets reviewers see the dashboard without any GCP credentials.
    """
    dates      = pd.date_range(start="2023-01-01", end="2023-12-31", freq="D")
    complaints = [
        "Noise - Residential", "Illegal Parking", "Blocked Driveway",
        "Street Condition", "Sanitation Condition", "HEAT/HOT WATER",
        "Request Large Bulky Item Collection", "Noise - Street/Sidewalk",
    ]
    boroughs   = ["MANHATTAN", "BROOKLYN", "QUEENS", "BRONX", "STATEN ISLAND"]

    np.random.seed(42)
    return pd.DataFrame({
        "created_date"  : np.random.choice(dates, 2000),
        "borough"       : np.random.choice(boroughs, 2000),
        "complaint_type": np.random.choice(complaints, 2000,
                            p=[0.22, 0.18, 0.15, 0.12, 0.10, 0.10, 0.07, 0.06]),
        "complaint_count": np.random.randint(5, 300, size=2000),
    })


# ── Load data with priority chain ─────────────────────────────────────────────
with st.spinner("Loading data..."):
    df = load_from_bigquery()
    data_source = "BigQuery (live)"

    if df is None:
        df = load_from_csv()
        data_source = "Local CSV export"

    if df is None:
        df = generate_sample_data()
        data_source = "Generated sample data"
        st.warning(
            "⚠️ No BigQuery credentials or local CSV found. "
            "Displaying generated sample data. "
            "See README for how to connect to BigQuery or export a CSV."
        )

st.caption(f"Data source: **{data_source}** — {len(df):,} rows loaded")

# ── Sidebar filters ───────────────────────────────────────────────────────────
st.sidebar.header("Filters")

all_boroughs = sorted(df["borough"].dropna().unique())
selected_boroughs = st.sidebar.multiselect(
    "Borough", all_boroughs, default=all_boroughs
)

all_types = sorted(df["complaint_type"].dropna().unique())
selected_types = st.sidebar.multiselect(
    "Complaint type", all_types, default=all_types
)

date_min = df["created_date"].min().date()
date_max = df["created_date"].max().date()
date_range = st.sidebar.date_input(
    "Date range",
    value=(date_min, date_max),
    min_value=date_min,
    max_value=date_max,
)

# Apply filters
mask = (
    df["borough"].isin(selected_boroughs)
    & df["complaint_type"].isin(selected_types)
)
if len(date_range) == 2:
    mask &= (
        (df["created_date"].dt.date >= date_range[0])
        & (df["created_date"].dt.date <= date_range[1])
    )
filtered = df[mask]

# ── KPI row ───────────────────────────────────────────────────────────────────
st.divider()
k1, k2, k3 = st.columns(3)
k1.metric("Total requests",   f"{filtered['complaint_count'].sum():,}")
k2.metric("Complaint types",  filtered["complaint_type"].nunique())
k3.metric("Boroughs covered", filtered["borough"].nunique())

# ── Row 1: Complaint type bar chart + Time series ─────────────────────────────
st.divider()
col1, col2 = st.columns(2)

with col1:
    st.subheader("Top complaint types")
    by_type = (
        filtered.groupby("complaint_type")["complaint_count"]
        .sum()
        .reset_index()
        .sort_values("complaint_count", ascending=False)
        .head(15)
    )
    fig_bar = px.bar(
        by_type,
        x="complaint_count",
        y="complaint_type",
        orientation="h",
        color="complaint_count",
        color_continuous_scale="Blues",
        labels={"complaint_count": "Total requests", "complaint_type": ""},
        text_auto=".2s",
    )
    fig_bar.update_layout(
        coloraxis_showscale=False,
        yaxis={"categoryorder": "total ascending"},
        margin=dict(l=0, r=0, t=0, b=0),
    )
    st.plotly_chart(fig_bar, use_container_width=True)

with col2:
    st.subheader("Daily complaint volume")
    daily = (
        filtered.groupby(filtered["created_date"].dt.date)["complaint_count"]
        .sum()
        .reset_index()
    )
    daily.columns = ["date", "total_requests"]
    fig_line = px.line(
        daily,
        x="date",
        y="total_requests",
        labels={"date": "Date", "total_requests": "Total requests"},
    )
    fig_line.update_traces(line_color="#1a6faf")
    fig_line.update_layout(margin=dict(l=0, r=0, t=0, b=0))
    st.plotly_chart(fig_line, use_container_width=True)

# ── Row 2: Borough breakdown ───────────────────────────────────────────────────
st.divider()
col3, col4 = st.columns(2)

with col3:
    st.subheader("Requests by borough")
    by_borough = (
        filtered.groupby("borough")["complaint_count"]
        .sum()
        .reset_index()
        .sort_values("complaint_count", ascending=False)
    )
    fig_pie = px.pie(
        by_borough,
        names="borough",
        values="complaint_count",
        hole=0.45,
        color_discrete_sequence=px.colors.qualitative.Set2,
    )
    fig_pie.update_layout(margin=dict(l=0, r=0, t=0, b=0))
    st.plotly_chart(fig_pie, use_container_width=True)

with col4:
    st.subheader("Borough × complaint type heatmap")
    pivot = (
        filtered.groupby(["borough", "complaint_type"])["complaint_count"]
        .sum()
        .reset_index()
    )
    top_types = (
        pivot.groupby("complaint_type")["complaint_count"]
        .sum()
        .nlargest(8)
        .index
    )
    pivot = pivot[pivot["complaint_type"].isin(top_types)]
    heat = pivot.pivot_table(
        index="borough", columns="complaint_type", values="complaint_count", fill_value=0
    )
    fig_heat = px.imshow(
        heat,
        color_continuous_scale="Blues",
        aspect="auto",
        labels={"color": "Requests"},
    )
    fig_heat.update_layout(
        xaxis_title="",
        yaxis_title="",
        margin=dict(l=0, r=0, t=0, b=0),
    )
    st.plotly_chart(fig_heat, use_container_width=True)

st.divider()
st.caption(
    "Pipeline: NYC Open Data API → dlt → BigQuery → dbt → Streamlit  |  "
    "See README for full setup instructions."
)
