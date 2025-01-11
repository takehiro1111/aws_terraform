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

###################################################################
# GithubActions
###################################################################
# GithubActions用のIAMロール,ポリシー --------------------------------------------------
// IAMロール,信頼ポリシーの設定
resource "aws_iam_role" "deploy_github_actions" {
  name = "deploy-github-actions"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity",
        Effect = "Allow"
        Principal = {
          Federated = module.oidc.oidc_arn
        },
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" : [
              "repo:takehiro1111/aws_terraform:*",
              "repo:takehiro1111/github_terraform:*",
              "repo:takehiro1111/ecs-learning-course:*",
              "repo:takehiro1111/docker:*",
              "repo:takehiro1111/serverless:*",
            ]
          }
        }
      }
    ]
  })
}

// 許可ポリシーの設定。
data "aws_iam_policy_document" "deploy_github_actions" {
  statement {
    effect = "Allow"
    actions = [
      "s3:*",
      "s3-object-lambda:*"
    ]
    resources = ["*"]
  }
  statement {
    sid       = "GithubActions"
    effect    = "Allow"
    actions   = ["sts:*"]
    resources = ["arn:aws:iam::${data.aws_caller_identity.self.account_id}:role/myaccount_actions"]
  }
  statement {
    sid    = "GetItem"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
    ]
    resources = ["arn:aws:dynamodb:ap-northeast-1:${data.aws_caller_identity.self.account_id}:table/tfstate-locks"]
  }
  statement {
    sid       = "PushECR"
    effect    = "Allow"
    actions   = ["ecr:*"]
    resources = ["*"]
  }
  statement {
    sid       = "DeployECS"
    effect    = "Allow"
    actions   = ["ecs:*"]
    resources = ["*"]
  }
  statement {
    sid     = "PassRole"
    effect  = "Allow"
    actions = ["iam:PassRole"]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.self.account_id}:role/ecsTaskExecutionRole",
      "arn:aws:iam::${data.aws_caller_identity.self.account_id}:role/secure-ecs-tasks-stg@common"
    ]
  }
  statement {
    sid     = "ALL"
    effect  = "Allow"
    actions = ["*"]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy" "deploy_github_actions" {
  name   = aws_iam_role.deploy_github_actions.name
  role   = aws_iam_role.deploy_github_actions.name
  policy = data.aws_iam_policy_document.deploy_github_actions.json
}
