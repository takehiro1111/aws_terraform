resource "aws_iam_role" "deploy_github_actions_plan" {
  name = "deploy-github-actions-plan"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity",
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_arn
        },
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" : var.github_actions_repo
          }
        }
      }
    ]
  })
}
data "aws_iam_policy" "deploy_github_actions_plan" {
  arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachments_exclusive" "deploy_github_actions_plan" {
  role_name   = aws_iam_role.deploy_github_actions_plan.name
  policy_arns = [data.aws_iam_policy.deploy_github_actions_plan.arn]
}


resource "aws_iam_role" "deploy_github_actions_apply" {
  name = "deploy-github-actions-apply"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity",
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_arn
        },
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" : var.github_actions_repo
          }
        }
      }
    ]
  })
}


data "aws_iam_policy" "deploy_github_actions_apply" {
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role_policy_attachments_exclusive" "deploy_github_actions_apply" {
  role_name   = aws_iam_role.deploy_github_actions_apply.name
  policy_arns = [data.aws_iam_policy.deploy_github_actions_apply.arn]
}

