# terraform/primitives/oidc-trust/main.tf
terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" { region = "us-east-1" }

# Required — no defaults. A default that pointed at GRCEngClub/cgep-app-starter
# would bind this role to the course demo repo, not yours (see GRCEngClub PR #9).
variable "github_org"  { type = string }
variable "github_repo" { type = string }

# Immutable OIDC ids (GitHub, repos created after 2026-07-15).
# From: gh api repos/<org>/<repo>/actions/oidc/customization/sub
variable "github_owner_id" { type = string }
variable "github_repo_id"  { type = string }

locals {
  classic_sub    = "repo:${var.github_org}/${var.github_repo}:*"
  immutable_sub  = "repo:${var.github_org}@${var.github_owner_id}/${var.github_repo}@${var.github_repo_id}:*"
}

resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  # Guide still lists DigiCert. GitHub's current chain is Let's Encrypt / ISRG.
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd",
    "2d74d6dfd96eea55ad7baafa0d3c6552b2dadc37",
    "ab9d0263244dd0326eb67015705a667e79cfe998",
  ]
}

resource "aws_iam_role" "grc_gate" {
  name = "cgep-grc-gate"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = { "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com" }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = [
            local.classic_sub,
            local.immutable_sub,
          ]
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "readonly" {
  role       = aws_iam_role.grc_gate.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

output "role_arn" { value = aws_iam_role.grc_gate.arn }
