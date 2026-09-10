# terraform/baselines/gcp/variables.tf
variable "gcp_project" {
  type        = string
  description = "GCP project ID for org policies, WIF pool, and audit configs."
}

variable "github_repo" {
  type        = string
  description = "OWNER/REPO that the WIF provider will trust."
}

# Project-scope Org Policy requires an Organization parent (Dex PR #18).
# This sandbox project is standalone; leave false so apply can complete.
variable "manage_org_policy" {
  type        = bool
  default     = false
  description = "Create google_org_policy_policy resources. Requires an Organization parent."
}
