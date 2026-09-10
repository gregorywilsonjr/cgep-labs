# Chain of custody write-up

Lab 4.4 turns the Lab 4.3 evidence artifact into a chain an auditor can verify
without trusting the operator. Four properties, four artifacts.

| Property | What it means | Artifact that proves it |
|---|---|---|
| **Authenticity** | The bundle came from this repository's `grc-gate` workflow, not from a laptop copy. | `${BUNDLE}.sig.bundle` — Cosign keyless signature. Fulcio bound a short-lived certificate to the GitHub OIDC identity (`https://token.actions.githubusercontent.com`). `cosign verify-blob` is the check. |
| **Integrity** | The bytes have not changed since the run. | `${BUNDLE}.sha256` — SHA-256 of `evidence-<run_id>-<sha>.tar.gz`. `verify-evidence.sh` recomputes the hash and requires an exact match. |
| **Timeliness** | There is an independent record of *when* it was signed. | The Rekor transparency-log entry inside the same `.sig.bundle`. Cosign verification fails if that log record is missing or does not match the blob. |
| **Preservation** | The object is still in the vault and still under retention. | S3 Object Lock on the Lab 2.5 vault (`GOVERNANCE`, 1-day lab retention). `s3api get-object-retention` must return a `RetainUntilDate` in the future. Overwrite of the same key is refused. |

The auditor's command is `scripts/verify-evidence.sh <run_id>`. Three checks, one
success line: `CHAIN INTACT`. A single-byte edit of the downloaded tarball fails
the integrity check immediately; Object Lock keeps the vault copy unchanged.

`evidence/lab-4-4/receipt.json` is the pointer: `run_id`, vault name, bundle key,
object `version_id`, SHA-256, and commit SHA.
