# declares variables

# defines a variable named project_id, replace this with your unique google cloud project iD
variable "project_id" {          
  description = "The GCP Project ID"
  type        = string
}


# defines a variable named region, replace this with name of region, select the region that best works for you
variable "region" {                
  description = "The GCP region"        
  default     = "us-central1"      
}


# defines a variable named gcs_bucket_name, replace this with your unique bucket name 
variable "gcs_bucket_name" {              
  description = "GCS Bucket Name" 
  type        = string
}


# defines a variable named bigquery_dataset_name, replace this with your unique bigquery dataset name
variable "bigquery_dataset_name" {             
  description = "Big Query Dataset"       
  type        = string
}


