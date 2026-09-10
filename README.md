# cgep-labs

Lab work for the **Certified GRC Engineer – Practitioner (CGE-P)** course.

Each lab produces a *compliant primitive*: a small piece of cloud infrastructure defined
entirely in code, where every security control is expressed as configuration a machine can
read — and proven by evidence generated on demand rather than collected by hand.

## Layout

| Path | Contents |
|------|----------|
| `terraform/primitives/` | Standalone infrastructure units, deployed directly |
| `terraform/baselines/` | Account-level security services (CloudTrail, Security Hub, GCP Org Policy / WIF) |
| `terraform/modules/` | Reusable modules other code references |
| `scripts/` | Shared utility scripts |
| `policies/` | Rego policies that refuse a non-compliant plan |
| `.github/workflows/` | CI gates that run those policies on every PR |
| `oscal/` | Machine-readable control claims (component + profile) |
| `evidence/` | Captured proof, one folder per lab |

## Labs

| Lab | Primitive | Controls | Evidence |
|-----|-----------|----------|----------|
| 2.3 | [`compliant-s3`](terraform/primitives/compliant-s3/) | SC-28, AC-3, AU-3, AU-6, CM-6 | [`evidence/lab-2-3/`](evidence/lab-2-3/) |
| 2.4 | [`compliant-gcs-bucket`](terraform/modules/compliant-gcs-bucket/) + [`compliant-gcs`](terraform/primitives/compliant-gcs/) | SC-12, SC-13, SC-28, AC-3, CM-6, AU-11 | [`evidence/lab-2-4/`](evidence/lab-2-4/) |
| 2.5 | [`evidence-vault`](terraform/primitives/evidence-vault/) + [`capture-evidence.sh`](scripts/capture-evidence.sh) | AU-9, AU-11 | [`evidence/lab-2-5/`](evidence/lab-2-5/) |
| 3.3 | [`policies/`](policies/) | SC-28, AC-3, CM-6 | [`evidence/lab-3-3/`](evidence/lab-3-3/) |
| 3.4 | [`policies/*_aws.rego`](policies/) + [`policy-gate.sh`](scripts/policy-gate.sh) | SC-28, AC-3, CM-6 (AWS) | [`evidence/lab-3-4/`](evidence/lab-3-4/) |
| 4.3 | [`oidc-trust`](terraform/primitives/oidc-trust/) + [`grc-gate.yml`](.github/workflows/grc-gate.yml) | CM-3, CM-6, CA-2, CA-7, RA-5, AU-9 | Actions artifact `grc-evidence-<run-id>` |
| 4.4 | Cosign keyless signing + [`verify-evidence.sh`](scripts/verify-evidence.sh) + Lab 2.5 vault | AU-9, AU-11 | [`evidence/lab-4-4/receipt.json`](evidence/lab-4-4/receipt.json) |
| 5.2 | [`baselines/aws`](terraform/baselines/aws/) | AU-2, AU-12, AU-10, RA-5, SI-4, CM-2, CM-6, CM-8 | [`evidence/lab-5-2/`](evidence/lab-5-2/) |
| 5.4 | [`baselines/gcp`](terraform/baselines/gcp/) + [`gcp-wif-demo.yml`](.github/workflows/gcp-wif-demo.yml) | CM-6, AC-2, AC-3, AU-2 | [`evidence/lab-5-4/iam-policy.json`](evidence/lab-5-4/iam-policy.json) |
| 6.1 | [`oscal/components/compliant-s3.json`](oscal/components/compliant-s3.json) + [`oscal/profiles/cge-p-minimum.json`](oscal/profiles/cge-p-minimum.json) | SC-28, AC-3, AU-3, CM-6 | [`evidence/lab-6-1/trestle-validate.txt`](evidence/lab-6-1/trestle-validate.txt) |

## About the evidence files

Lab 2.3 commits `plan.json` and `state.json` (`terraform show -json`): what was declared
before apply and what was recorded after. Lab 2.4 commits `plan.json` and
`attestation.json`. Lab 3.3 commits `opa-test-results.json` from `opa test --format=json`.
Lab 3.4 commits `conftest-pass.json` and `conftest-fail.json` from `scripts/policy-gate.sh`.
Lab 4.3 evidence is the GitHub Actions artifact (`plan.json`, `conftest-results.json`,
`tfsec.sarif`, `plan.txt`) attached to each `grc-gate` run. Lab 4.4 signs that bundle
into the Lab 2.5 vault and commits `evidence/lab-4-4/receipt.json`;
`scripts/verify-evidence.sh` is the auditor check (`CHAIN INTACT`). Keep the OIDC
provider, `cgep-grc-gate` role, and vault while that chain is being demonstrated.
Live cloud resources are destroyed once evidence is captured — the evidence stands on its
own. The vault is the exception during Lab 4.4: Object Lock is the preservation
property, so it is left standing until retention expires.
Lab 5.2 evidence is `evidence/lab-5-2/security-hub-findings.json` from
`aws securityhub get-findings`. The CloudTrail trail and Security Hub
standards are destroyed after capture so the per-check bill stops.
Lab 5.4 evidence is `evidence/lab-5-4/iam-policy.json` (Data Access audit
configs). WIF is left standing so `.github/workflows/gcp-wif-demo.yml` can
authenticate without a JSON key.
Lab 6.1 evidence is `evidence/lab-6-1/trestle-validate.txt` (`VALID` from
`trestle` for the component definition and the profile). The component's
evidence `href`s point at the Lab 4.4 vault object with a `versionId`.

Terraform working files — `.terraform/`, `.terraform.lock.hcl`, `*.tfstate`, `tfplan`,
`*.tfvars` — are excluded by `.gitignore`. They are machine-specific and can carry
sensitive values.
