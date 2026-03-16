# declares variables

# defines a variable named project_id, replace this with your unique google cloud project iD
variable "project_id" {          
  description = "project-bdcd6ccf-5abd-43e1-a88"
  type        = string
}


# defines a variable named region, replace this with name of region, select the region that best works for you
variable "region" {                
  description = "GCP region"        
  default     = "us-central1"      
}


# defines a variable named gcs_bucket_name, replace this with your unique bucket name 
variable "gcs_bucket_name" {              
  description = "nyc-311-gcs-data-lake" 
  type        = string
}


# defines a variable named bigquery_dataset_name, replace this with your unique bigquery dataset name
variable "bigquery_dataset_name" {             
  description = "nyc_311_bigquery_dataset"       
  type        = string
}
