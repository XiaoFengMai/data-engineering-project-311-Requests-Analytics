# Looker Studio Dashboard — Setup Guide

This guide walks you through building the NYC 311 dashboard in Looker Studio
in about 10 minutes, connected to your BigQuery data.

---

## Prerequisites

- BigQuery dataset is live and dbt models have been run (`dbt run`)
- You have run `looker_studio_views.sql` in the BigQuery console to create the six views
- You are signed into the same Google account that owns the GCP project

---

## Step 1 — Open Looker Studio and create a new report

1. Go to [https://lookerstudio.google.com](https://lookerstudio.google.com)
2. Click **Blank Report**
3. When prompted to add a data source, choose **BigQuery**
4. Authorize access to your GCP project if prompted

---

## Step 2 — Connect all six data sources

You need one data source per view. Repeat for each:

1. In the **Add data** panel: My Projects → `YOUR_PROJECT_ID` → `nyc_311_bigquery_dataset`
2. Select the view (listed below) → click **Add**
3. Rename each data source in the top-left to something readable

| View name | Rename to |
|---|---|
| `v_complaints_by_type` | Complaints by Type |
| `v_complaints_by_borough` | Complaints by Borough |
| `v_complaints_over_time` | Complaints Over Time |
| `v_fact_complaints_summary` | Fact Complaints |
| `v_kpi_summary` | KPI Summary |
| `v_complaints_by_agency` | Complaints by Agency |

---

## Step 3 — Build the scorecard row (4 KPI tiles)

Data source: **KPI Summary**

1. Insert → **Scorecard** (repeat 4 times)
2. Arrange them in a single row across the top
3. Configure each:

| Scorecard | Metric field | Label |
|---|---|---|
| 1 | `total_requests` | Total Requests |
| 2 | `unique_complaint_types` | Complaint Types |
| 3 | `avg_resolution_hours` | Avg Resolution (hrs) |
| 4 | `open_requests` | Open Requests |

4. Style → set font size to 28, add a colored top border:
   - Scorecard 1: blue (`#1a73e8`)
   - Scorecard 2: green (`#34a853`)
   - Scorecard 3: yellow (`#fbbc04`)
   - Scorecard 4: red (`#ea4335`)

---

## Step 4 — Tile 1: Top complaint types (horizontal bar chart)

Data source: **Complaints by Type**

1. Insert → **Bar chart**
2. Set chart to **Horizontal bar**
3. Dimension: `complaint_type`
4. Metric: `total_requests`
5. Sort: `total_requests` Descending
6. Style tab → set **Bars to show** to 10
7. Resize to fill the left two-thirds of the page

---

## Step 5 — Tile 2: Complaints by borough (pie chart)

Data source: **Complaints by Borough**

1. Insert → **Pie chart**
2. Dimension: `borough`
3. Metric: `total_requests`
4. Style tab → enable **Donut** mode
5. Place to the right of the bar chart

---

## Step 6 — Tile 3: Daily complaint volume (time-series line chart)

Data source: **Complaints Over Time**

1. Insert → **Time series chart**
2. Dimension: `request_date` (set granularity to **Day**)
3. Metric: `total_requests`
4. Style tab → set line color to `#1a73e8`, enable **Smooth**
5. Stretch full width below the two categorical tiles
6. Optional: add a second metric `total_requests` with a moving-average trendline

---

## Step 7 — Bonus tile: Borough × Complaint Type heatmap

Data source: **Fact Complaints**

1. Insert → **Pivot table with heatmap**
2. Row dimension: `complaint_type`
3. Column dimension: `borough`
4. Metric: `complaint_count` (aggregation: Sum)
5. Style tab → enable **Heatmap** coloring on the metric column
6. Stretch full width at the bottom of the report

---

## Step 8 — Add filter controls (sidebar / top bar)

1. Insert → **Date range control**
   - Default date range: **Custom** → Jan 1 2020 → Today

2. Insert → **Drop-down list** control (repeat for each filter below):

| Control | Data source | Dimension |
|---|---|---|
| Borough | Complaints by Borough | `borough` |
| Status | Complaints by Type | `status` |
| Agency | Complaints by Agency | `agency` |

3. Select all controls → right-click → **Make report-level filters**
   (this makes them affect all charts simultaneously)

---

## Step 9 — Set up auto-refresh

1. File → **Report settings**
2. Set **Data freshness** to **12 hours** (or 1 hour if you want near-real-time)

This means the dashboard pulls the latest BigQuery data automatically when
your Prefect pipeline loads new records daily.


---

## Troubleshooting

| Problem | Fix |
|---|---|
| "No data" in charts | Run `dbt run` first, then verify the BigQuery views exist |
| Permission denied | In BigQuery IAM, grant your Looker Studio service account `BigQuery Data Viewer` |
| Date filter not working | Ensure `request_date` is set as type **Date** (not String) in the data source schema |
| Slow loading | In Report settings, enable **Data caching** |
