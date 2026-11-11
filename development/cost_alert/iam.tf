#####################################################
# Lambda 実行ロール
#####################################################
data "aws_iam_policy_document" "alert_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "alert" {
  name               = local.name
  assume_role_policy = data.aws_iam_policy_document.alert_assume_role.json
}

resource "aws_iam_role_policy_attachment" "alert_basic_execution" {
  role       = aws_iam_role.alert.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "alert_operations" {
  statement {
    sid       = "AssumeCostExplorerReaderRole"
    actions   = ["sts:AssumeRole"]
    resources = ["arn:aws:iam::${local.management_account_id}:role/${local.reader_role_name}"]
  }

  statement {
    sid       = "ReadSlackWebhookUrl"
    actions   = ["ssm:GetParameter"]
    resources = ["arn:aws:ssm:ap-northeast-1:${data.aws_caller_identity.self.account_id}:parameter${local.slack_webhook_parameter_name}"]
  }
}

resource "aws_iam_role_policy" "alert_operations" {
  name   = "${local.name}-operations"
  role   = aws_iam_role.alert.id
  policy = data.aws_iam_policy_document.alert_operations.json
}

#####################################################
# EventBridge Scheduler 用ロール
#####################################################
data "aws_iam_policy_document" "scheduler_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.self.account_id]
    }
  }
}

resource "aws_iam_role" "scheduler" {
  name               = "${local.name}-scheduler"
  assume_role_policy = data.aws_iam_policy_document.scheduler_assume_role.json
}

data "aws_iam_policy_document" "scheduler_invoke" {
  statement {
    sid       = "InvokeAlertFunction"
    actions   = ["lambda:InvokeFunction"]
    resources = [aws_lambda_function.alert.arn]
  }
}

resource "aws_iam_role_policy" "scheduler_invoke" {
  name   = "${local.name}-scheduler-invoke"
  role   = aws_iam_role.scheduler.id
  policy = data.aws_iam_policy_document.scheduler_invoke.json
}
