# configures google cloud as the cloud provider


# opens the main terraform configuration block used to configure behavior and requirements, download provider from google by hashicorp version 5. something
terraform {                    
  required_providers {                
    google = {                         
      source = "hashicorp/google" 
      version = "~> 5.0"          
    }
  }
}


# sets up credentials and defaults for all google resources in your project,  sets default GCP project to deploy resources into, sets default GCP region for resources
provider "google" {              
  project = var.project_id                
  region = var.region                              
}
