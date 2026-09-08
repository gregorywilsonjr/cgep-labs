# compliant-gcs-bucket

Provisions a GCS bucket with a customer-managed encryption key and a compliance floor that
consumers cannot disable through the module's inputs.

## What it creates

One KMS key ring, one crypto key, one key-access grant for the Cloud Storage service agent,
and one bucket.

## Controls — implementation relationships

| ID | Name | How this module relates to it |
|----|------|-------------------------------|
| SC-12 | Cryptographic Key Establishment | Dedicated key ring and key whose permissions, rotation and lifecycle this project controls. Google hosts KMS. |
| SC-13 | Cryptographic Protection | Symmetric key, `GOOGLE_SYMMETRIC_ENCRYPTION`, 90-day rotation schedule. |
| SC-28 | Protection of Information at Rest | Bucket default encryption bound to that key. |
| AC-3 | Access Enforcement | `public_access_prevention = "enforced"`, uniform bucket-level access. |
| CM-6 | Configuration Settings | Four required labels merged over any caller-supplied labels. |
| AU-11 | Audit Record Retention | Versioning plus a retention policy. This lab stores no audit records, so the relationship is mechanical, not a satisfied control. |

These are relationships, not claims of full control satisfaction. See
[NIST SP 800-53 Rev. 5](https://csrc.nist.gov/pubs/sp/800/53/r5/upd1/final).

## Interface

Callers may set `gcp_project`, `project_label`, `environment`, `retention_days`,
`bucket_name_suffix`, `location`, `kms_location`, and extra `labels`.

Callers may **not** disable encryption, public access prevention, uniform bucket-level
access, or versioning. No input exists for any of them. Anyone able to edit this module or
change Google Cloud directly can still bypass it; that is what code review, IAM,
organization policy and monitoring are for.

## Outputs

`bucket_url`, `bucket_self_link`, `kms_key_id`, and `compliance_attestation` — a
configuration summary read from Terraform state. Verify it against Google Cloud rather than
treating it as an inspection.

## Validation

`retention_days` carries a cross-variable rule: when `environment` is `prod`, retention must
be at least 365 days. It fails at `terraform plan`, before any resource exists. Requires
Terraform >= 1.9.

## This exercise

Dev was applied and its bucket kept empty. Evidence is `plan.json` and `attestation.json`
in `evidence/lab-2-4/`.

Adapted from GRC Engineering Club's CGE-P Lab 2.4 (MIT). See the repository root for the
full notice.
