# Policy library

Rego policies enforced against `terraform plan -json` output. Each rule maps to one
NIST 800-53 control and every deny message names both the resource and the control.

| Policy | Control | Severity | Applies to | Remediation |
|---|---|---|---|---|
| `sc28_encryption.rego` | SC-28 | high | `google_storage_bucket` | Add an `encryption { default_kms_key_name = … }` block referencing a KMS key you control |
| `ac3_no_public.rego` | AC-3 | critical | `google_storage_bucket`, `google_compute_firewall` | Set `uniform_bucket_level_access = true` and `public_access_prevention = "enforced"`; narrow firewall `source_ranges` off `0.0.0.0/0` for ports 22 and 3389 |
| `cm6_required_tags.rego` | CM-6 | medium | `google_storage_bucket`, `google_compute_instance`, `google_compute_disk` | Add the four required labels: `project`, `environment`, `managed_by`, `compliance_scope` |

## Running them

    opa test -v policies/                      # unit tests, no cloud needed
    opa eval -d policies -i <plan.json> data.compliance.<pkg>.deny --format=pretty

## Scope and limits

- GCP only. AWS variants arrive in Lab 3.4.
- Both `deny` paths cover top-level and `child_modules` resources.
- SC-28 requires the `encryption` block to exist, not the key value to be resolved: at plan
  time a newly created key is "known after apply" and omitted from the JSON.
- `terraform/primitives/policy-fixture/` is a plan-only test bed, not a deployed workload.
- Lab 3.3 used Path B: policies were evaluated against a hand-authored `plan.json` that
  preserves `encryption: [{}]` for CMEK buckets, not a live GCP plan. The fixture was left
  in the broken (demo) state so each violation still fires once.
