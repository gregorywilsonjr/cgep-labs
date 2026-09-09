# Policy library

Rego policies enforced against `terraform plan -json` output. Each rule maps to one
NIST 800-53 control and every deny message names the resource and the control. The
control ID is the same on both clouds; the resource types are not.

| Policy | Cloud | Control | Severity | Applies to | Remediation |
|---|---|---|---|---|---|
| `sc28_encryption.rego` | GCP | SC-28 | high | `google_storage_bucket` | Add an `encryption { default_kms_key_name = … }` block referencing a KMS key you control |
| `sc28_encryption_aws.rego` | AWS | SC-28 | high | `aws_s3_bucket` | Add `aws_s3_bucket_server_side_encryption_configuration` that references the bucket |
| `ac3_no_public.rego` | GCP | AC-3 | critical | `google_storage_bucket`, `google_compute_firewall` | Set `uniform_bucket_level_access = true` and `public_access_prevention = "enforced"`; narrow firewall `source_ranges` off `0.0.0.0/0` for ports 22 and 3389 |
| `ac3_no_public_aws.rego` | AWS | AC-3 | critical | `aws_s3_bucket` | Add `aws_s3_bucket_public_access_block` with all four flags true |
| `cm6_required_tags.rego` | GCP | CM-6 | medium | `google_storage_bucket`, `google_compute_instance`, `google_compute_disk` | Add the four required labels: `project`, `environment`, `managed_by`, `compliance_scope` |
| `cm6_required_tags_aws.rego` | AWS | CM-6 | medium | `aws_s3_bucket`, `aws_dynamodb_table`, `aws_lambda_function`, `aws_kms_key`, `aws_cloudtrail` | Add the four required tags: `Project`, `Environment`, `ManagedBy`, `ComplianceScope` (or set them with provider `default_tags`) |

## Running them

    opa test -v policies/                      # unit tests, no cloud needed
    opa eval -d policies -i <plan.json> data.compliance.<pkg>.deny --format=pretty

    # Lab 3.4 gate (AWS namespaces only — GCP namespaces pass with zero coverage on an AWS plan)
    bash scripts/policy-gate.sh --workspace terraform/primitives/compliant-s3

## Scope and limits

- GCP files from Lab 3.3; AWS files (`*_aws.rego`) from Lab 3.4. Same three control IDs.
- Both GCP deny paths cover top-level and `child_modules` resources. AWS SC-28 and AC-3
  match by Terraform reference in `configuration`, not by literal bucket name.
- SC-28 (GCP) requires the `encryption` block to exist, not the key value to be resolved:
  at plan time a newly created key is "known after apply" and omitted from the JSON.
- `scripts/policy-gate.sh` is the fail-closed wrapper Lab 4.3 calls. It evaluates
  `compliance.sc28_aws`, `compliance.ac3_aws`, and `compliance.cm6_aws` only.
- `terraform/primitives/policy-fixture/` is a plan-only GCP test bed, not a deployed workload.
- Lab 3.3 used Path B: policies were evaluated against a hand-authored `plan.json` that
  preserves `encryption: [{}]` for CMEK buckets, not a live GCP plan. The fixture was left
  in the broken (demo) state so each violation still fires once.
