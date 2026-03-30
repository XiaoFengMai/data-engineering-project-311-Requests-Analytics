# create resources (data lake bucket cloud storage for raw data storage, bigquery dataset data warehouse for analytics)


# declares a new GCS bucket resource with gcs as resource type and data lake bucket as local reference name, sets standard storage class which is best for frequently accessed data
resource "google_storage_bucket" "data_lake_bucket" {      
  name          = var.gcs_bucket_name                     
  location      = var.region                 
  storage_class = "STANDARD"                
  force_destroy = true

 # allows terraform to delete the bucket even if it still contains files
  uniform_bucket_level_access = true         

# opens a version configuration block for the bucket, turn on object versioning so GCP can keep a history of all file versions.
  versioning {                
    enabled = true                    
  }
}




# create data warehouse dataset in bigquery, declares new bigquery dataset resource with resource type and dataset, sets bigquery dataset id
resource "google_bigquery_dataset" "dataset" {     
  dataset_id  = var.bigquery_dataset_name            
  location    = var.region         
  description = "NYC 311 analytics dataset"        
}

