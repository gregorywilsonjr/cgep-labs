# terraform/modules/compliant-gcs-bucket/outputs.tf

output "bucket_url" {
  value       = google_storage_bucket.bucket.url
  description = "The gs:// address of the practice bucket."
}

output "bucket_self_link" {
  value       = google_storage_bucket.bucket.self_link
  description = "API self-link for the practice bucket."
}

output "kms_key_id" {
  value       = google_kms_crypto_key.key.id
  description = "Full resource name of the practice encryption key."
}

output "compliance_attestation" {
  description = "Configuration summary from Terraform state; verify against Google Cloud."

  value = {
    # Provider-reported key template value, not a hand-written label.
    encryption_algorithm     = google_kms_crypto_key.key.version_template[0].algorithm
    default_kms_key_name     = google_storage_bucket.bucket.encryption[0].default_kms_key_name
    versioning_enabled       = google_storage_bucket.bucket.versioning[0].enabled
    public_access_prevention = google_storage_bucket.bucket.public_access_prevention
    uniform_access_enforced  = google_storage_bucket.bucket.uniform_bucket_level_access
    retention_period_days    = google_storage_bucket.bucket.retention_policy[0].retention_period / 86400
    retention_policy_locked  = google_storage_bucket.bucket.retention_policy[0].is_locked
    required_labels_present = alltrue([
      for k in keys(local.required_labels) : contains(keys(google_storage_bucket.bucket.labels), k)
    ])
    required_label_values_match = alltrue([
      for k, v in local.required_labels : lookup(google_storage_bucket.bucket.labels, k, "") == v
    ])
    kms_rotation_period = google_kms_crypto_key.key.rotation_period
  }
}