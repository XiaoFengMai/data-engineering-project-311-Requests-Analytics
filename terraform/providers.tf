# configures google cloud as the cloud provider


terraform {                    # opens the main terraform configuration block used to configure behavior and requirements
  required_providers {                # declares which external providers this project depends on
    google = {                              # provider is google
      source = "hashicorp/google"                    # tells terraform to downlaod the provider from official google provider by hashicorp
      version = "~> 5.0"                    # selects any version 5.0 to the highest 5. version
    }
  }
}

provider "google" {              # sets up credentials and defaults for all google resources in your project
  project = var.project_id                # set the default GCP project to deploy resources into
  region = var.region                              # sets defauly GCP region for resources
}
