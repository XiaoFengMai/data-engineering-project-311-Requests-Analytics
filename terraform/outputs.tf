# values that Terraform prints after deployment

output "bucket_name" {
  value = google_storage_bucket.data_lake_bucket.name
}

output "bigquery_dataset" {
  value = google_bigquery_dataset.dataset.dataset_id
}



# after running terraform, you should see

#bucket_name = nyc-311-data-lake
#bigquery_dataset = nyc_311_dataset
