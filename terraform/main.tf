# create resources (data lake bucket cloud storage for raw data storage, bigquery dataset data warehouse for analytics)

resource "google_storage_bucket" "data_lake_bucket" {            # declares a new GCS bucket resource with gsc as the resource type and data lake bucket is used as a local reference name 
  name          = var.gcs_bucket_name                      # sets the actual bucket name in GCP *must be globally unqique*, pulled from a variable
  location      = var.region                        # sets the geographic region where the bucket is be created
  storage_class = "STANDARD"                  # sets the storage class to standard which is best for frequently accessed data
  force_destroy = true

  uniform_bucket_level_access = true          # allows terraform to delete the bucket even if it still contains files

  versioning {                # opens a version configuration block for the bucket
    enabled = true                    # turns on object versioning so GCP can keep a history of all file versions.
  }
}




# create data warehouse dataset in bigquery

resource "google_bigquery_dataset" "dataset" {          # declares a new BigQuery dataset resource with google bq ds as resource type and dataset as local reference name
  dataset_id  = var.bq_dataset_name                # sets the bigquery dataset id pulled from a variable
  location    = var.region                # sets region using variable
  description = "NYC 311 analytics dataset"        
}

