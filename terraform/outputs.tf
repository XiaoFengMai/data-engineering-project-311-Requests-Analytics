# values that Terraform prints after a successful terraform apply


# declares an output variable bucket_name and tells terraform to display name attribute as the value
output "bucket_name" {               
  value = google_storage_bucket.data_lake_bucket.name      
}

# declares a second output variable named binquery_dataset and reads data_id attribute as variable
output "bigquery_dataset" {   
  value = google_bigquery_dataset.dataset.dataset_id   
}



# after running terraform, you should see

# bucket_name = nyc-311-data-lake
# bigquery_dataset = nyc_311_dataset
