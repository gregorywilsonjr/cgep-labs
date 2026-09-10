# terraform/baselines/aws/security_hub.tf
# enable_default_standards defaults to true and is ForceNew. Declaring false
# avoids a destructive hub replacement and keeps CIS defaults from billing
# alongside the two standards this lab actually subscribes to (Dex, PR #12).
resource "aws_securityhub_account" "this" {
  enable_default_standards = false
}

resource "aws_securityhub_standards_subscription" "nist_800_53" {
  standards_arn = "arn:aws:securityhub:${var.aws_region}::standards/nist-800-53/v/5.0.0"
  depends_on    = [aws_securityhub_account.this]
}

resource "aws_securityhub_standards_subscription" "fsbp" {
  standards_arn = "arn:aws:securityhub:${var.aws_region}::standards/aws-foundational-security-best-practices/v/1.0.0"
  depends_on    = [aws_securityhub_account.this]
}
