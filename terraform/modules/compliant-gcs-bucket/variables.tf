# terraform/modules/compliant-gcs-bucket/variables.tf

variable "gcp_project" {
  type        = string
  description = "Google Cloud project ID for this practice deployment."
}

variable "location" {
  type        = string
  description = "Bucket location; keep us-central1 for this walkthrough."
  default     = "us-central1"
}

variable "kms_location" {
  type        = string
  description = "KMS location, which must be compatible with the bucket location."
  default     = "us-central1"

  validation {
    condition     = lower(var.kms_location) == lower(var.location)
    error_message = "For this walkthrough, bucket and KMS locations must match."
  }
}

variable "project_label" {
  type        = string
  description = "Short label used in resource names."

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,20}$", var.project_label))
    error_message = "project_label must be 3-21 lowercase letters, digits, or hyphens; start with a letter."
  }
}

variable "environment" {
  type        = string
  description = "dev, staging, or prod."

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod."
  }
}

variable "retention_days" {
  type        = number
  description = "Whole days to retain objects. This lab requires at least 365 for prod."

  validation {
    condition = (
      var.retention_days >= 1 &&
      var.retention_days <= 3650 &&
      floor(var.retention_days) == var.retention_days
    )
    error_message = "retention_days must be a whole number from 1 through 3650."
  }

  validation {
    condition     = var.environment != "prod" || var.retention_days >= 365
    error_message = "retention_days must be >= 365 when environment == prod."
  }
}

variable "bucket_name_suffix" {
  type        = string
  description = "Personal suffix; use a different dev and prod prefix."

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,28}[a-z0-9]$", var.bucket_name_suffix))
    error_message = "Suffix must be 3-30 lowercase letters, digits, or hyphens; start and end with a letter or digit."
  }
}

variable "labels" {
  type        = map(string)
  description = "Optional additional labels. Required module values win conflicts."
  default     = {}
}