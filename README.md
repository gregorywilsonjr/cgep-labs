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
| `evidence/` | Captured proof, one folder per lab |

## Labs

| Lab | Primitive | Controls | Evidence |
|-----|-----------|----------|----------|
| 2.3 | [`compliant-s3`](terraform/primitives/compliant-s3/) | SC-28, AC-3, AU-3, AU-6, CM-6 | [`evidence/lab-2-3/`](evidence/lab-2-3/) |

## About the evidence files

`plan.json` and `state.json` are committed deliberately. They are `terraform show -json`
output: machine-readable records of what was declared and what was actually built.
`plan.json` shows a control was satisfied *before* deployment; `state.json` shows it was in
place *after*. Live AWS resources are destroyed once evidence is captured — the evidence
stands on its own.

Terraform working files — `.terraform/`, `.terraform.lock.hcl`, `*.tfstate`, `tfplan`,
`*.tfvars` — are excluded by `.gitignore`. They are machine-specific and can carry
sensitive values.
