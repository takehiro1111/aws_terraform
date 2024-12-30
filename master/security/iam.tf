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

###################################################################
# Authentication for HCP Terraform
###################################################################
module "iam_role_hcp" {
  source = "../../modules/iam/hcp"
}
