# Compliant S3 Primitive

This module enforces SC-28, AU-3, AU-6, CM-6, and AC-3 on a single S3 bucket.
SC-28 is satisfied by AES-256 server-side encryption; AC-3 by a full public
access block on both buckets; AU-3 and AU-6 by S3 server access logging to a
separate, equally hardened log bucket; and CM-6 by provider-level default_tags
and object versioning. Evidence is emitted as JSON via `terraform show -json`
for both the plan (pre-deployment) and the state (post-deployment).