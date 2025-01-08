###################################################################
# Github Actions
###################################################################
# Github Actions --------------------------------------------------------------------
module "oidc_github_actions" {
  source = "../../modules/iam/oidc"
}

module "iam_role_github_actions_deploy" {
  source              = "../../modules/iam/github_actions_deploy"
  oidc_arn            = module.oidc_github_actions.oidc_arn
  github_actions_repo = ["repo:takehiro1111/aws_terraform:*"]
}

resource "aws_iam_role" "github_actions_for_waf" {
  name = "deploy-github-actions-for-waf"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity",
        Effect = "Allow"
        Principal = {
          Federated = module.oidc_github_actions.oidc_arn
        },
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" : [
              "repo:takehiro1111/aws_terraform:*",
            ]
          }
        }
      }
    ]
  })
}

###################################################################
# Authentication for HCP Terraform
###################################################################
module "iam_role_hcp" {
  source = "../../modules/iam/hcp"
}


locals {
  name = toset(["test1-5"])
}

resource "aws_iam_user" "test" {
  for_each = local.name
  name     = each.key
}
