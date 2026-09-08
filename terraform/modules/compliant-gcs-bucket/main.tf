# terraform/modules/compliant-gcs-bucket/main.tf

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
  required_labels = {
    project          = var.project_label
    environment      = var.environment
    managed_by       = "terraform"
    compliance_scope = "cge-p-lab"
  }

  # For duplicate keys the later map wins, so required labels take priority.
  effective_labels = merge(var.labels, local.required_labels)
  bucket_name      = "${var.project_label}-${var.environment}-${var.bucket_name_suffix}"
  keyring_id       = "${var.bucket_name_suffix}-ring"
  key_id           = "${var.bucket_name_suffix}-key"
}

# Look up the project's Cloud Storage service identity.
data "google_storage_project_service_account" "gcs" {
  project = var.gcp_project
}

# SC-12: a dedicated key ring. Google hosts KMS; you control the key's settings.
resource "google_kms_key_ring" "ring" {
  name     = local.keyring_id
  location = var.kms_location
  project  = var.gcp_project
}

# SC-13 / SC-28: symmetric key with a 90-day rotation schedule.
resource "google_kms_crypto_key" "key" {
  name            = local.key_id
  key_ring        = google_kms_key_ring.ring.id
  rotation_period = "7776000s" # 90 days in seconds.

  version_template {
    algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
    protection_level = "SOFTWARE"
  }

  # Allows practice cleanup. Real data needs a reviewed key-lifecycle design.
  lifecycle {
    prevent_destroy = false
  }
}

# Let Cloud Storage encrypt and decrypt using this particular key.
resource "google_kms_crypto_key_iam_member" "gcs_encrypter" {
  crypto_key_id = google_kms_crypto_key.key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${data.google_storage_project_service_account.gcs.email_address}"
}

# AC-3 + SC-28 + CM-6 + AU-11 in one resource declaration.
resource "google_storage_bucket" "bucket" {
  name          = local.bucket_name
  project       = var.gcp_project
  location      = var.location
  force_destroy = false # Do not silently delete objects during cleanup.

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }

  encryption {
    default_kms_key_name = google_kms_crypto_key.key.id
  }

  retention_policy {
    retention_period = var.retention_days * 86400
    is_locked        = false # Leave this false for the entire lab.
  }

  labels = local.effective_labels

  # Grant key permission before creating the bucket that uses the key.
  depends_on = [google_kms_crypto_key_iam_member.gcs_encrypter]
}
