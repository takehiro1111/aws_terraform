#####################################################
# Chatbot（Slack 通知）
#####################################################
data "aws_iam_policy_document" "chatbot_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["chatbot.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "chatbot" {
  name               = "${local.name}-chatbot"
  assume_role_policy = data.aws_iam_policy_document.chatbot_assume_role.json
}

resource "aws_iam_role_policy_attachment" "chatbot_read_only" {
  role       = aws_iam_role.chatbot.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

// NOTE: Slack ワークスペースの認可は master アカウントの Chatbot コンソールで事前に 1 回行う（Terraform では扱えない）
resource "aws_chatbot_slack_channel_configuration" "anomaly" {
  configuration_name    = local.name
  iam_role_arn          = aws_iam_role.chatbot.arn
  slack_team_id         = data.terraform_remote_state.master_account_management.outputs.slack_workspace_id
  slack_channel_id      = data.terraform_remote_state.master_account_management.outputs.slack_channel_id_aws_alert
  sns_topic_arns        = [aws_sns_topic.anomaly.arn]
  guardrail_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  logging_level         = "ERROR"

  tags = {
    Name = local.name
  }
}
