# AWS security services baseline (Lab 5.2)

Account-level continuous monitoring: CloudTrail records what happened,
AWS Config records what each resource looked like, and Security Hub
aggregates findings against NIST 800-53 and FSBP.

Config is optional in the published walkthrough (org SCPs often block
it). This sandbox has no org, and Hub standards stayed `INCOMPLETE` with
`NO_AVAILABLE_CONFIGURATION_RECORDER` until a recorder existed, so
`config.tf` is deployed.

| Service | Controls | How this lab proves it |
|---|---|---|
| **CloudTrail** (`cloudtrail.tf`) | **AU-2**, **AU-12**, **AU-10** | Multi-region management-event trail `cgep-lab-mgmt` with `enable_log_file_validation = true`. AU-2/AU-12 are the event capture; AU-10 is the hourly signed digest that detects after-the-fact tampering. |
| **Security Hub** (`security_hub.tf`) | **RA-5**, **SI-4** | Hub enabled with `enable_default_standards = false`, then subscribed to NIST 800-53 Rev 5 and AWS Foundational Security Best Practices. Findings are captured in `evidence/lab-5-2/security-hub-findings.json`. |
| **AWS Config** (`config.tf`) | **CM-2**, **CM-6**, **CM-8** | Recorder `cgep-lab-recorder` with all-supported + global types, delivery to a dedicated bucket, using `AWSServiceRoleForConfig`. A custom Config role was not enough: Hub stayed `INCOMPLETE` until the service-linked role was in place. |

`enable_default_standards = false` is required: the provider default is
`true` and ForceNew. An empty `aws_securityhub_account` body would either
enable extra CIS checks (cost) or replace an existing hub.

Live resources are destroyed after evidence is captured so the standards
stop billing. The committed JSON is the artifact.

Findings were also stored in the Lab 2.5 vault (Object Lock) as
`runs/lab-5-2/security-hub-findings.json`, VersionId
`04lAN4vMGkiiy_hHsE65zypplKVXdXyX`. That is a `put-object` of the same
JSON, not a Cosign-signed Lab 4.4 bundle.
