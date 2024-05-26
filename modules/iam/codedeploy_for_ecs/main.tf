resource "aws_iam_role" "bulue_green_deploy_for_ECS" {
  name = "bulue-green-deploy-for-ECS"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      }
    ]
  })
}

data "aws_iam_policy" "bulue_green_deploy_for_ECS" {
  arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}

resource "aws_iam_role_policy" "bulue_green_deploy_for_ECS" {
  name   = aws_iam_role.bulue_green_deploy_for_ECS.name
  role   = aws_iam_role.bulue_green_deploy_for_ECS.name
  policy = data.aws_iam_policy.bulue_green_deploy_for_ECS.policy
}
