# terraform/baselines/gcp/main.tf
terraform {
  required_version = ">= 1.6"
  required_providers {
    google = { source = "hashicorp/google", version = "~> 5.0" }
  }
}

# user_project_override + billing_project are required with ADC.
# Without them orgpolicy/cloudresourcemanager bill quota to Google's
# default project 764086051850 and fail with SERVICE_DISABLED (Dex PR #16).
provider "google" {
  project               = var.gcp_project
  region                = "us-central1"
  user_project_override = true
  billing_project       = var.gcp_project
}
