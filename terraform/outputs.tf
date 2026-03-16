# values that Terraform prints after a successful terraform apply

output "bucket_name" {               # declares a output variable named bucket_name
  value = google_storage_bucket.data_lake_bucket.name        # tells terraform to display the name attribute as the value
}

output "bigquery_dataset" {          # declares a second output variable named bigquery_dataset
  value = google_bigquery_dataset.dataset.dataset_id         # reads the dataset_id attribute as the value
}



# after running terraform, you should see

#bucket_name = nyc-311-data-lake
#bigquery_dataset = nyc_311_dataset
