"""
config.py
---------
Central constants for the ingestion pipeline.
Import these instead of hard-coding values in individual scripts.
"""

# NYC Open Data — 311 Service Requests (dataset ID: erm2-nwe9)
API_ENDPOINT = "https://data.cityofnewyork.us/resource/erm2-nwe9.json"

# Maximum rows fetched per API call (Socrata API cap is 50 000 without offset pagination)
LIMIT = 50_000

# Column names expected from the API (used for validation / DataFrame filtering)
EXPECTED_COLUMNS = [
    "unique_key",
    "created_date",
    "closed_date",
    "complaint_type",
    "descriptor",
    "agency",
    "status",
    "borough",
    "latitude",
    "longitude",
]
