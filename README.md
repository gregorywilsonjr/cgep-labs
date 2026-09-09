# cgep-labs

Lab work for the **Certified GRC Engineer – Practitioner (CGE-P)** course.

Each lab produces a *compliant primitive*: a small piece of cloud infrastructure defined
entirely in code, where every security control is expressed as configuration a machine can
read — and proven by evidence generated on demand rather than collected by hand.

## Layout

| Path | Contents |
|------|----------|
| `terraform/primitives/` | Standalone infrastructure units, deployed directly |
| `terraform/modules/` | Reusable modules other code references |
| `scripts/` | Shared utility scripts |
| `policies/` | Rego policies that refuse a non-compliant plan |
| `evidence/` | Captured proof, one folder per lab |

## Labs

| Lab | Primitive | Controls | Evidence |
|-----|-----------|----------|----------|
| 2.3 | [`compliant-s3`](terraform/primitives/compliant-s3/) | SC-28, AC-3, AU-3, AU-6, CM-6 | [`evidence/lab-2-3/`](evidence/lab-2-3/) |
| 2.4 | [`compliant-gcs-bucket`](terraform/modules/compliant-gcs-bucket/) + [`compliant-gcs`](terraform/primitives/compliant-gcs/) | SC-12, SC-13, SC-28, AC-3, CM-6, AU-11 | [`evidence/lab-2-4/`](evidence/lab-2-4/) |
| 2.5 | [`evidence-vault`](terraform/primitives/evidence-vault/) + [`capture-evidence.sh`](scripts/capture-evidence.sh) | AU-9, AU-11 | [`evidence/lab-2-5/`](evidence/lab-2-5/) |
| 3.3 | [`policies/`](policies/) | SC-28, AC-3, CM-6 | [`evidence/lab-3-3/`](evidence/lab-3-3/) |

## About the evidence files

Lab 2.3 commits `plan.json` and `state.json` (`terraform show -json`): what was declared
before apply and what was recorded after. Lab 2.4 commits `plan.json` and
`attestation.json`. Lab 3.3 commits `opa-test-results.json` from `opa test --format=json`.
Live cloud resources are destroyed once evidence is captured — the evidence stands on its
own.

Terraform working files — `.terraform/`, `.terraform.lock.hcl`, `*.tfstate`, `tfplan`,
`*.tfvars` — are excluded by `.gitignore`. They are machine-specific and can carry
sensitive values.
