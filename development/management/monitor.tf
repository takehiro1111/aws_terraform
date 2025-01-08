
#####################################################
# CloudTrail Event Notification
#####################################################
# module "cloudtrail_event_notify_development" {
#   source = "../../modules/event_bridge/cloudtrail"
# }

#####################################################
# EventBridge
#####################################################
/* 
 * ECS Task STOPPED Event 
 */
// ref: https://registry.terraform.io/modules/terraform-aws-modules/eventbridge/aws/latest
module "event_bridge_ecs_stopped" {
  source  = "terraform-aws-modules/eventbridge/aws"
  version = "3.14.1"

  create              = true
  create_role         = false
  create_bus          = false
  append_rule_postfix = false
  rules = {
    ecs_event_notify = {
      name          = "ecs-event-notify"
      bus_name      = "default"
      enabled       = "ENABLED"
      description   = "${local.env_yml.env} ecs alert notification rule"
      event_pattern = <<END
        {
          "source": ["aws.ecs"],
          "detail-type": [
            "ECS Task State Change"
          ],
          "detail": {
            "lastStatus": [
              "STOPPED"
            ],
            "clusterArn": [
              "${data.terraform_remote_state.development_compute.outputs.ecs_cluster_arn_web}"
            ]
          }
        }
      END
    }
  }
  targets = {
    ecs_event_notify = [{
      name = "ecs-event-notify"
      arn  = module.sns_notify_chatbot.topic_arn
      input_transformer = {
        input_paths = {
          "group" : "$.detail.group",
          "taskDefinitionArn" : "$.detail.taskDefinitionArn",
          "stoppedAt" : "$.detail.stoppedAt",
          "stopCode" : "$.detail.stopCode",
          "stoppedReason" : "$.detail.stoppedReason",
        }
        input_template = <<END
        {
        "version": "1.0",
        "source": "custom",
        "content": {
          "textType": "client-markdown",
          "title": ":warning: ECSタスクが停止されました :warning:",
          "description": "@channel\nOverview\n ・Service:`<group>`\n・Task: `<taskDefinitionArn>`\n・StoppedAt: `<stoppedAt>(UTC)`\n・StopCode: `<stopCode>`\n・StoppedReason: `<stoppedReason>`"
        }
      }
        END
      }
    }]
  }

  tags = {
    Name = "ecs-event-stopped-notify"
  }
}

/* 
 * Event for ECS Schedule AutoScaling
 */
// ref: https://registry.terraform.io/modules/terraform-aws-modules/eventbridge/aws/latest
module "event_bridge_ecs_autoscaling" {
  source  = "terraform-aws-modules/eventbridge/aws"
  version = "3.14.1"

  create              = true
  create_role         = false
  create_bus          = false
  append_rule_postfix = false

  rules = {
    ecs_autoscaling_update_service = {
      name        = "ecs-autoscaling-update-service"
      bus_name    = "default"
      enabled     = "ENABLED"
      description = "Capture UpdateService events triggered by ECS AutoScaling"
      event_pattern = jsonencode({
        detail-type = [
          "AWS API Call via CloudTrail"
        ]
        detail = {
          eventName   = ["UpdateService"]
          eventSource = ["ecs.amazonaws.com"]
          requestParameters = {
            service = [data.terraform_remote_state.development_compute.outputs.ecs_service_name_web_nginx]
            cluster = [data.terraform_remote_state.development_compute.outputs.ecs_cluster_name_web]
          }
          userAgent = ["ecs.application-autoscaling.amazonaws.com"]
        }
      })
    }
  }

  targets = {
    ecs_autoscaling_update_service = [{
      name = "ecs-autoscaling-update-service-notification"
      arn  = aws_cloudwatch_log_group.events_app_autoscaling.arn
    }]
  }

  tags = {
    Name = "ecs-autoscaling-update-service"
  }
}


# // ref: https://registry.terraform.io/modules/terraform-aws-modules/eventbridge/aws/latest
module "event_bridge_ecs_app_autoscaling" {
  source  = "terraform-aws-modules/eventbridge/aws"
  version = "3.14.1"

  create              = true
  create_role         = false
  create_bus          = false
  append_rule_postfix = false
  rules = {
    ecs_app_auto_scaling_activity = {
      name        = "event-ecs-app-auto-scaling"
      bus_name    = "default"
      enabled     = "ENABLED"
      description = "event-ecs-app-auto-scaling"
      event_pattern = jsonencode({
        detail-type = [
          "AWS API Call via CloudTrail"
        ]
        detail = {
          eventName   = ["UpdateService"]
          eventSource = ["ecs.amazonaws.com"]
          requestParameters = {
            service = [data.terraform_remote_state.development_compute.outputs.ecs_service_name_web_nginx]
            cluster = [data.terraform_remote_state.development_compute.outputs.ecs_cluster_name_web]
          }
          userAgent = ["ecs.application-autoscaling.amazonaws.com"]
        }
      })
    }
  }
  targets = {
    ecs_app_auto_scaling_activity = [{
      name = "ecs-app-auto-scaling-activity"
      arn  = module.sns_notify_chatbot.topic_arn
      input_transformer = {
        input_paths = {
          "service" : "$.detail.requestParameters.service",
          "runningCount" : "$.detail.responseElements.service.runningCount",
          "desiredCount" : "$.detail.responseElements.service.desiredCount",
        }
        input_template = <<END
        {
          "version": "1.0",
          "source": "custom",
          "content": {
            "textType": "client-markdown",
            "title": ":chart_with_upwards_trend: ECS Application AutoScaling Activity",
            "description": "@channel\nService: `<service>`\nRunning:`<runningCount>`\nDesired:`<desiredCount>`"
          }
        }
        END
      }
    }]
  }

  tags = {
    Name = "ecs-app-auto-scaling-activity"
  }
}

# resource "aws_cloudwatch_event_rule" "update_waf_rule" {
#   name        = "update_waf_rule"
#   description = "Trigger Lambda function on UpdateWebACL for specific WAF rule"

#   event_pattern = jsonencode({
#     source = ["aws.waf"],
#     detail-type =  ["AWS API Call via CloudTrail"],
#     detail =  {
#       eventSource = ["waf.amazonaws.com"],
#       eventName = ["UpdateWebACL"],
#       requestParameters =  {
#         rules = {
#           name = ["CountOtherRegions"]
#         }
#       }
#     }
#   })
# }

# resource "aws_cloudwatch_event_target" "lambda_target" {
#   rule      = aws_cloudwatch_event_rule.update_waf_rule.name
#   target_id = "update_waf_rule_lambda"
#   arn       = aws_lambda_function.update_waf_rule.arn
# }

#####################################################
# AWS Config
#####################################################
module "aws_config_organizations" {
  source                     = "../../modules/config"
  create                     = false // コストかかるため、falseにしておく。
  recorder_status_is_enabled = false

  name                = format("%s-%s", local.env_yml.env, data.aws_caller_identity.self.account_id)
  recording_frequency = "DAILY"
  s3_bucket_name      = data.terraform_remote_state.master_storage.outputs.s3_bucket_id_config_audit_log

  use_exclude_specific_resource_types = true
  configuration_recorder_exclusion_by_resource_types = [
    "AWS::EC2::NetworkInterface"
  ]

  config_rules = {
    s3_bucket_versioning_enabled = {
      source_identifier         = "S3_BUCKET_VERSIONING_ENABLED"
      compliance_resource_types = ["AWS::S3::Bucket"]
    }
  }
}

#####################################################
# BudGet
#####################################################
locals {
  monthly_budget = {
    low    = 3
    middle = 5
    high   = 10
  }
}

resource "aws_budgets_budget" "notify_slack" {
  name              = "monthly-budget"
  budget_type       = "COST"
  limit_amount      = 70
  limit_unit        = "USD"
  time_period_start = "2024-08-01_00:00"
  time_unit         = "MONTHLY"

  cost_types {
    include_tax     = true
    include_support = true
  }

  # SNS,Eメールアドレスへの通知設定
  dynamic "notification" {
    for_each = { for k, v in local.monthly_budget : k => v }
    content {
      comparison_operator        = "GREATER_THAN"
      notification_type          = "ACTUAL"
      threshold                  = notification.value
      threshold_type             = "ABSOLUTE_VALUE"
      subscriber_sns_topic_arns  = [aws_sns_topic.slack_alert.arn]
      subscriber_email_addresses = [module.value.my_gmail_address, module.value.company_mail_address]
    }
  }
}

######################################################################
# SSM ParameterStore
######################################################################
locals {
  slack_info = {
    notify_slack_workspace = {
      name        = "/slack/workspace_id/personal"
      description = "個人用のSlackワークスペースID"
    }
    notify_slack_channel = {
      name        = "/slack/channel_id/aws_alert"
      description = "通知用のSlackチャンネルID"
    }
  }
}

resource "aws_ssm_parameter" "slack_info" {
  for_each    = { for k, v in local.slack_info : k => v }
  name        = each.value.name
  provider    = aws.us-east-1
  description = each.value.description
  type        = "SecureString"
  value       = "コンソール画面で設定する。"

  lifecycle {
    ignore_changes = [value]
  }
}

# Aurora ---------------------------------
resource "aws_ssm_parameter" "aurora_mysql" {
  name        = "/aurora/MYSQL_PASSWORD"
  description = "Aurora MYSQL Master Password"
  type        = "SecureString"
  value       = "画面上から対応"

  lifecycle {
    ignore_changes = [value]
  }
}

# Lambda ---------------------------------
resource "aws_ssm_parameter" "slack_webhook_url" {
  name        = "/app/personal/SLACK_WEBHOOK_URL"
  description = "Slack Webhook lambda_notify channel"
  type        = "SecureString"
  value       = "画面上から対応"

  lifecycle {
    ignore_changes = [value]
  }
}

######################################################################
# SNS
######################################################################
#trivy:ignore:avd-aws-0095 //(HIGH): Topic does not have encryption enabled.
resource "aws_sns_topic" "slack_alert" {
  name     = "slack-alert"
  provider = aws.us-east-1
}

resource "aws_sns_topic_policy" "slack_alert" {
  arn      = aws_sns_topic.slack_alert.arn
  provider = aws.us-east-1
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "budgets.amazonaws.com"
        },
        Action   = "SNS:Publish",
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

// ref: https://registry.terraform.io/modules/terraform-aws-modules/sns/aws/latest
module "sns_notify_chatbot" {
  source  = "terraform-aws-modules/sns/aws"
  version = "6.1.2"

  create       = true
  name         = "slack_notify"
  display_name = "slack_notify"

  create_topic_policy = false
  topic_policy        = data.aws_iam_policy_document.sns_notify_chatbot.json
}

data "aws_iam_policy_document" "sns_notify_chatbot" {
  statement {
    sid    = "AWSEvents_EcsEvent"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
    actions = ["sns:Publish"]
    resources = [
      "arn:aws:sns:ap-northeast-1:${data.aws_caller_identity.self.account_id}:slack_notify"
    ]
  }
}

// ref: https://registry.terraform.io/modules/terraform-aws-modules/sns/aws/latest
module "sns_notify_chatbot_ecs_cw_alert" {
  source  = "terraform-aws-modules/sns/aws"
  version = "6.1.2"

  create       = true
  name         = "sns_notify_chatbot_ecs_cw_alert"
  display_name = "sns_notify_chatbot_ecs_cw_alert"

  create_topic_policy = false
}

######################################################################
# Chatbot
######################################################################
locals {
  chatbots = {
    personal = {
      name               = "common-alert-notify"
      slack_workspace_id = module.value.slack_workspace_id
      slack_channel_id   = module.value.aws_alert_slack_channel_id
    }
  }
}

resource "aws_chatbot_slack_channel_configuration" "dev" {
  for_each = { for k, v in local.chatbots : k => v }

  configuration_name = each.key
  guardrail_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]
  iam_role_arn     = data.terraform_remote_state.development_security.outputs.iam_role_arn_chatbot
  slack_team_id    = each.value.slack_workspace_id
  slack_channel_id = each.value.slack_channel_id
  logging_level    = "ERROR"
  sns_topic_arns = [
    aws_sns_topic.slack_alert.arn,
    module.sns_notify_chatbot.topic_arn,
    module.sns_notify_chatbot_ecs_cw_alert.topic_arn,
    # module.cloudtrail_event_notify_development.sns_topic_arn
  ]

  tags = {
    Name = each.key
  }
}
