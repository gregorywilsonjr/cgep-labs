# GCP security services baseline (Lab 5.4)

Identity-first preventive controls: Org Policy rejects a bad API call,
Workload Identity Federation replaces downloadable service-account keys,
and Data Access logs record reads and writes once you turn them on.

## Data Access logs are off by default

That default is the lesson. Admin Activity logs exist without any action;
DATA_READ / DATA_WRITE / ADMIN_READ for Storage, KMS, and IAM do not.
`audit_logs.tf` turns them on. Evidence is
`evidence/lab-5-4/iam-policy.json` (`gcloud projects get-iam-policy
--format=json(auditConfigs)`).

## Controls

| Layer | Controls | How this lab proves it |
|---|---|---|
| Org Policy (`org_policy.tf`) | CM-6, AC-2, AC-3 | Intended: `storage.uniformBucketLevelAccess`, `iam.disableServiceAccountKeyCreation`, `compute.requireOsLogin` enforced at the API. This project has **no Organization parent**, so `orgpolicy.policies.create` was denied on `projects/cge-practice` (Dex PR #18). `manage_org_policy` stays false. Equivalents: Lab 2.4 uniform bucket access; WIF instead of JSON keys; no Compute VMs in this lab. |
| WIF (`wif.tf`) | AC-2 | Pool `github-actions` trusts only `gregorywilsonjr/cgep-labs` via `attribute_condition`. Bound to `cgep-grc-gate-sa` (`roles/viewer`). Demo: `.github/workflows/gcp-wif-demo.yml`. |
| Data Access logs (`audit_logs.tf`) | AU-2 | Storage, Cloud KMS, and IAM audit configs as above. |

Never loosen the WIF `attribute_condition`. Without it, any GitHub
repository could present an OIDC token and impersonate the service
account — the same class of mistake as a wide AWS OIDC `sub`.

WIF pools enter a 30-day soft-delete, so this baseline is left standing
(Org Policy and WIF are free; Data Access log volume on an empty project
is pennies).
