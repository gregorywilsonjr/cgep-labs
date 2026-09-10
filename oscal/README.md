# OSCAL documents

Machine-readable control claims for this repo. An assessor starts here,
follows an evidence `href` into the Lab 2.5 vault, and runs
`scripts/verify-evidence.sh`.

| Document | Describes | Evidence |
|---|---|---|
| [`components/compliant-s3.json`](components/compliant-s3.json) | Terraform primitive [`terraform/primitives/compliant-s3`](../terraform/primitives/compliant-s3/) (Lab 2.3). Implements SC-28, AC-3, AU-3, and CM-6. | Lab 4.4 signed bundle `s3://cgep-lab-grc-evidence-vault-9d3abfe7/runs/34522029255/evidence-34522029255-34efc62834b18e726dc8871875a7d65dfa050b93.tar.gz?versionId=BPWbVu_X3leKYhpSIHx0kKR84SDRrNC9` (receipt in [`evidence/lab-4-4/receipt.json`](../evidence/lab-4-4/receipt.json)). |
| [`profiles/cge-p-minimum.json`](profiles/cge-p-minimum.json) | Selects those four NIST 800-53 Rev 5 control IDs from the public catalog. | The profile is the selection, not the proof. Proof is the component's evidence links. |

`oscal-version` is **1.2.1**, matching `trestle version` (compliance-trestle 5.1.0). The published lab snippet still says 1.1.3; mixing versions fails validation.

Authoring happens in `.trestle-work/` (gitignored). These files are the copies trestle validated.
