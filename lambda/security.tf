#####################################################################
# IAM
#####################################################################
/* 
 * Lambda WAF Create Delete Execute Role
 */
resource "aws_iam_role" "lambda_execute_waf" {
  name = "lambda-execute-waf"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

data "aws_iam_policy_document" "lambda_execute_waf" {
  statement {
    effect = "Allow"
    actions = [
      "wafv2:CreateRule",
      "wafv2:DeleteRule",
      "wafv2:UpdateWebACL",
      "wafv2:GetWebACL",
      "wafv2:ListWebACLs"
    ]
    resources = ["arn:aws:wafv2:us-east-1:${data.aws_caller_identity.current.account_id}:global/webacl/*/*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:${data.aws_region.default.name}:${data.aws_caller_identity.current.account_id}:log-group:*:*"]
  }
}

resource "aws_iam_role_policy" "lambda_execute_waf" {
  name   = aws_iam_role.lambda_execute_waf.name
  role   = aws_iam_role.lambda_execute_waf.name
  policy = data.aws_iam_policy_document.lambda_execute_waf.json
}
