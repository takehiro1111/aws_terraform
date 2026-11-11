#####################################################
# Lambda（全アカウントの週次コスト比較を Slack に通知）
#####################################################
#trivy:ignore:avd-aws-0017 //(LOW): Log group is not encrypted with a CMK.
resource "aws_cloudwatch_log_group" "alert" {
  name              = "/aws/lambda/${local.name}"
  retention_in_days = 14
}

// NOTE: dist/ は追跡しない。apply の前に function/all_accounts_cost_alert で pnpm install && pnpm build を実行する
data "archive_file" "alert" {
  type        = "zip"
  source_dir  = local.lambda_dist_dir
  output_path = "${path.module}/build/lambda.zip"
}

#trivy:ignore:avd-aws-0066 //(LOW): Function does not have tracing enabled.
resource "aws_lambda_function" "alert" {
  function_name    = local.name
  role             = aws_iam_role.alert.arn
  filename         = data.archive_file.alert.output_path
  source_code_hash = data.archive_file.alert.output_base64sha256
  handler          = "index.handler"
  runtime          = "nodejs22.x"
  architectures    = ["arm64"]
  memory_size      = 256
  timeout          = 60

  environment {
    variables = {
      MANAGEMENT_ACCOUNT_ID            = local.management_account_id
      READER_ROLE_NAME                 = local.reader_role_name
      PARAMETER_NAME_SLACK_WEBHOOK_URL = local.slack_webhook_parameter_name
      INCREASE_RATIO_THRESHOLD         = local.increase_ratio_threshold
      INCREASE_USD_THRESHOLD           = local.increase_usd_threshold
    }
  }

  depends_on = [aws_cloudwatch_log_group.alert]
}
