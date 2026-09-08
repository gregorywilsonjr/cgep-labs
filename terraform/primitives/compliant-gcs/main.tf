# terraform/primitives/compliant-gcs/main.tf
terraform {
  required_version = ">= 1.9, < 2.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

locals {
  gcp_project = "cge-practice"
  run_tag     = "lab-20260907-6184"
}

provider "google" {
  project = local.gcp_project
  region  = "us-central1"
}

module "data_bucket" {
  source = "../../modules/compliant-gcs-bucket"

  gcp_project        = local.gcp_project
  project_label      = "cgep-lab"
  environment        = "dev"
  retention_days     = 30
  bucket_name_suffix = "dev-${local.run_tag}"
}

output "attestation" { value = module.data_bucket.compliance_attestation }
output "bucket_url" { value = module.data_bucket.bucket_url }
output "kms_key_id" { value = module.data_bucket.kms_key_id }