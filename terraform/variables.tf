# declares variable

variable "project_id" {          #defines a variable named project_id
  description = "project-bdcd6ccf-5abd-43e1-a88"  # replace this with your unique google cloud project iD
  type        = string
}

variable "region" {                #defines a variable named region
  description = "GCP region"       # replace this with name of region
  default     = "us-central1"      # select the region that best works for you
}

variable "gcs_bucket_name" {              #defines a variable named gcs_bucket_name
  description = "nyc-311-gcs-data-lake"       # replace this with your unique bucket name 
  type        = string
}

variable "bigquery_dataset_name" {             # defines a variable named bigquery_dataset_name
  description = "nyc_311_bigquery_dataset"        # replace this with your unique bigquery dataset name
  type        = string
}
