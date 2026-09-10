# terraform/baselines/gcp/org_policy.tf
# Intended API-layer rejection (CM-6 / AC-2 / AC-3). These resources only
# apply when var.manage_org_policy is true — standalone projects cannot
# call orgpolicy.policies.create (Dex PR #18).
resource "google_org_policy_policy" "uniform_bucket_access" {
  count  = var.manage_org_policy ? 1 : 0
  name   = "projects/${var.gcp_project}/policies/storage.uniformBucketLevelAccess"
  parent = "projects/${var.gcp_project}"

  spec {
    rules { enforce = "TRUE" }
  }
}

resource "google_org_policy_policy" "disable_sa_keys" {
  count  = var.manage_org_policy ? 1 : 0
  name   = "projects/${var.gcp_project}/policies/iam.disableServiceAccountKeyCreation"
  parent = "projects/${var.gcp_project}"

  spec {
    rules { enforce = "TRUE" }
  }
}

resource "google_org_policy_policy" "require_oslogin" {
  count  = var.manage_org_policy ? 1 : 0
  name   = "projects/${var.gcp_project}/policies/compute.requireOsLogin"
  parent = "projects/${var.gcp_project}"

  spec {
    rules { enforce = "TRUE" }
  }
}
