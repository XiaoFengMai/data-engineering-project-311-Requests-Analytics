-- ─────────────────────────────────────────────────────────────────────────────
-- Run these in BigQuery to create the views that Looker Studio connects to.
-- Each view maps to one chart/tile in the Looker Studio dashboard.
-- Replace `YOUR_PROJECT_ID` and `nyc_311_bigquery_dataset` with your values.
-- ─────────────────────────────────────────────────────────────────────────────


-- ── View 1: Complaints by type (Tile 1 — horizontal bar chart) ────────────────
-- Mirrors complaints_by_type.sql in dbt
-- Used by: Looker Studio bar chart → dimension=complaint_type, metric=total_requests
CREATE OR REPLACE VIEW `YOUR_PROJECT_ID.nyc_311_bigquery_dataset.v_complaints_by_type` AS
SELECT
    complaint_type,
    COUNT(*) AS total_requests
FROM `YOUR_PROJECT_ID.nyc_311_bigquery_dataset.int_311_cleaned`
GROUP BY complaint_type
ORDER BY total_requests DESC;


-- ── View 2: Complaints by borough (Tile 2 — pie chart) ────────────────────────
-- Mirrors complaints_by_borough.sql in dbt
-- Used by: Looker Studio pie chart → dimension=borough, metric=total_requests
CREATE OR REPLACE VIEW `YOUR_PROJECT_ID.nyc_311_bigquery_dataset.v_complaints_by_borough` AS
SELECT
    borough,
    COUNT(*) AS total_requests
FROM `YOUR_PROJECT_ID.nyc_311_bigquery_dataset.stg_311_requests`
WHERE borough IS NOT NULL
GROUP BY borough
ORDER BY total_requests DESC;


-- ── View 3: Complaints over time (Tile 3 — time-series line chart) ────────────
-- Mirrors complaints_over_time.sql in dbt
-- Used by: Looker Studio time-series → dimension=request_date, metric=total_requests
CREATE OR REPLACE VIEW `YOUR_PROJECT_ID.nyc_311_bigquery_dataset.v_complaints_over_time` AS
SELECT
    DATE(created_date)  AS request_date,
    COUNT(*)            AS total_requests
FROM `YOUR_PROJECT_ID.nyc_311_bigquery_dataset.stg_311_requests`
GROUP BY request_date
ORDER BY request_date;


-- ── View 4: Fact complaints (heatmap + borough filter card) ───────────────────
-- Mirrors fact_311_complaints.sql (partitioned + clustered table)
-- Used by: Looker Studio pivot/heatmap → row=complaint_type, col=borough
CREATE OR REPLACE VIEW `YOUR_PROJECT_ID.nyc_311_bigquery_dataset.v_fact_complaints_summary` AS
SELECT
    created_date,
    borough,
    complaint_type,
    SUM(complaint_count) AS complaint_count
FROM `YOUR_PROJECT_ID.nyc_311_bigquery_dataset.fact_311_complaints`
GROUP BY created_date, borough, complaint_type;


-- ── View 5: KPI scorecard metrics (for the 4 summary scorecards at top) ───────
-- Single-row view that Looker Studio scorecards point to
CREATE OR REPLACE VIEW `YOUR_PROJECT_ID.nyc_311_bigquery_dataset.v_kpi_summary` AS
SELECT
    COUNT(*)                                                      AS total_requests,
    COUNT(DISTINCT complaint_type)                                AS unique_complaint_types,
    COUNT(DISTINCT borough)                                       AS boroughs_active,
    ROUND(AVG(resolution_time_hours), 1)                         AS avg_resolution_hours,
    COUNTIF(LOWER(status) IN ('open','in progress','pending'))   AS open_requests
FROM `YOUR_PROJECT_ID.nyc_311_bigquery_dataset.int_311_cleaned`;


-- ── View 6: Agency breakdown (bonus tile — ranked bar) ────────────────────────
CREATE OR REPLACE VIEW `YOUR_PROJECT_ID.nyc_311_bigquery_dataset.v_complaints_by_agency` AS
SELECT
    agency,
    COUNT(*)  AS total_requests,
    ROUND(AVG(resolution_time_hours), 1) AS avg_resolution_hours
FROM `YOUR_PROJECT_ID.nyc_311_bigquery_dataset.int_311_cleaned`
WHERE agency IS NOT NULL
GROUP BY agency
ORDER BY total_requests DESC;
