#####################################################
# Cloudwatch Alerm
#####################################################


#####################################################
# BudGet
#####################################################
locals {
  monthly_budget = {
    test   = 2
    low    = 10
    middle = 20
    high   = 30
  }
}

resource "aws_budgets_budget" "notify_slack" {
  name              = "monthly-budget"
  budget_type       = "COST"
  limit_amount      = 30
  limit_unit        = "USD"
  time_period_start = "2024-08-01_00:00"
  time_unit         = "MONTHLY"

  cost_types {
    include_tax     = true
    include_support = true
  }

  # SNS通知の設定
  dynamic "notification" {
    for_each = { for k, v in local.monthly_budget : k => v }
    content {
      comparison_operator = "GREATER_THAN"
      notification_type   = "ACTUAL"
      threshold           = notification.value
      threshold_type      = "ABSOLUTE_VALUE"
      subscriber_sns_topic_arns = [aws_sns_topic.slack_alert.arn]
    }
  }
}

######################################################################
# SNS
######################################################################
resource "aws_sns_topic" "slack_alert" {
  name     = "slack-alert"
  provider = aws.us-east-1
}

resource "aws_sns_topic_policy" "slack_alert" {
  arn = aws_sns_topic.slack_alert.arn
  provider = aws.us-east-1
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "budgets.amazonaws.com"
        },
        Action = "SNS:Publish",
        Resource = aws_sns_topic.slack_alert.arn,
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.self.account_id
          }
        }
      }
    ]
  })
}

######################################################################
# SSM ParameterStore
######################################################################
locals {
  slack_info = {
    notify_slack_workspace = {
      name = "/slack/workspace_id/personal"
      description = "個人用のSlackワークスペースID"
    }
    notify_slack_channel = {
      name  = "/slack/channel_id/aws_alert"
      description = "通知用のSlackチャンネルID"
    }
  }
}

resource "aws_ssm_parameter" "slack_info" {
  for_each = { for k,v in local.slack_info : k => v }
  name  = each.value.name
  provider = aws.us-east-1
  description = each.value.description
  type  = "SecureString"
  value = "コンソール画面で設定する。"

  lifecycle {
    ignore_changes = [value]
  }
}

data "aws_ssm_parameter" "notify_slack_workspace" {
  name = "/slack/workspace_id/personal"
}

data "aws_ssm_parameter" "notify_slack_channel" {
  name = "/slack/channel_id/aws_alert"
}

######################################################################
# Chatbot
######################################################################
locals {
  chatbots = {
    my_account = {
      name               = "common-alert-notify"
      slack_workspace_id = "T06PFGXUB2B" # personal 
      slack_channel_id   = "C07GTL63RDJ" # aws_alert
    }
  }
}

resource "awscc_chatbot_slack_channel_configuration" "notify_slack" {
  for_each           = { for k, v in local.chatbots : k => v }
  configuration_name = each.key
  iam_role_arn       = aws_iam_role.chatbot.arn
  guardrail_policies = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
  ]
  slack_channel_id   = each.value.slack_channel_id
  slack_workspace_id = each.value.slack_workspace_id
  logging_level      = "ERROR"
  sns_topic_arns     = [aws_sns_topic.slack_alert.arn]
  user_role_required = true

  tags = [
    {
      key   = "Name"
      value = each.key
    }
  ]
}
