/*
 * Lambda Error Alert
 */
module "lambda_error" {
  source      = "../../modules/cloudwatch/lambda_monitor/"
  param       = var.lambda
  sns_arn     = "arn:aws:sns:ap-northeast-1:685339645368:test"
  destination = "arn:aws:logs:ap-northeast-1:685339645368:log-group:/test/lambda_monitor"
  role_arn    = aws_iam_role.cloudwatch_to_lambda.arn
}

resource "aws_cloudwatch_log_group" "var_lambda_monitor" {
  name = "/var/lambda_monitor"
}


resource "aws_cloudwatch_log_group" "this" {
  name = "/test/lambda_monitor"
}


resource "aws_iam_role" "cloudwatch_to_lambda" {
  name = "cloudwatch-to-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "logs.amazonaws.com"
        }
      }
    ]
  })
}

data "aws_iam_policy" "cloudwatch_to_lambda" {
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_to_lambda" {
  role       = aws_iam_role.cloudwatch_to_lambda.name
  policy_arn = data.aws_iam_policy.cloudwatch_to_lambda.arn
}
