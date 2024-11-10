#####################################################
# Cloudwatch Logs
#####################################################
# ECS -----------------------------------------
resource "aws_cloudwatch_log_group" "ecs_nginx" {
  retention_in_days = 1
  name              = "/ecslogs/nginx"
}

# EC2 ------------------------------------------
resource "aws_cloudwatch_log_group" "public_instance" {
  name              = "/compute/ec2/public"
  log_group_class   = "STANDARD"
  skip_destroy      = true
  retention_in_days = 1
}

# VPCフローログ --------------------------------
resource "aws_cloudwatch_log_group" "flow_log" {
  name              = "/vpc/flow-log"
  log_group_class   = "STANDARD"
  skip_destroy      = true
  retention_in_days = 1
}

#####################################################
# EventBridge
#####################################################
/* 
 * ECS Task STOPPED Event 
 */
// ref: https://registry.terraform.io/modules/terraform-aws-modules/eventbridge/aws/latest
# module "event_bridge_ecs_stopped" {
#   source  = "terraform-aws-modules/eventbridge/aws"
#   version = "3.12.0"

#   create              = true
#   create_role         = false
#   create_bus          = false
#   append_rule_postfix = false
#   rules = {
#     ecs-event-notify = {
#       name          = "ecs-event-notify"
#       bus_name      = "default"
#       enabled       = "ENABLED"
#       description   = "${local.env_yml.env} ecs alert notification rule"
#       event_pattern = <<END
#         {
#           "source": ["aws.ecs"],
#           "detail-type": [
#             "ECS Task State Change"
#           ],
#           "detail": {
#             "lastStatus": [
#               "STOPPED"
#             ],
#             "clusterArn": [
#               "${aws_ecs_cluster.web.arn}"
#             ]
#           }
#         }
#       END
#     }
#   }
#   targets = {
#     ecs-event-notify = [{
#       name = "ecs-event-notify"
#       arn  = module.sns_notify_chatbot.topic_arn
#       input_transformer = {
#         input_paths = {
#           "group" : "$.detail.group",
#           "taskDefinitionArn" : "$.detail.taskDefinitionArn",
#           "stoppedAt" : "$.detail.stoppedAt",
#           "stopCode" : "$.detail.stopCode",
#           "stoppedReason" : "$.detail.stoppedReason",
#         }
#         input_template = <<END
#         {
#           "version": "1.0",
#           "source": "custom",
#           "content": {
#             "textType": "client-markdown",
#             "title": ":warning: ECSタスクが停止されました :warning:",
#             "description": "overview\n ・Service:`<group>`\n・Task: `<taskDefinitionArn>`\n・stoppedAt: `<stoppedAt>(UTC)`\n・stopCode: `<stopCode>`\n・stoppedReason: `<stoppedReason>`"
#           }
#         }
#         END
#       }
#     }]
#   }

#   tags = {
#     Name = "ecs-event-stopped-notify"
#   }
# }

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

######################################################################
# Config
######################################################################


#####################################################
# BudGet
#####################################################
locals {
  monthly_budget = {
    low    = 50
    middle = 60
    high   = 70
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

#####################################################
# Kinesis Data Firehose
#####################################################
locals {
  common_delivery = {
    common_vpc_flow_logs = {
      create     = true
      name       = "delivery-vpc-flow-logs"
      index_name = "comon_vpc_flow_logs"
    }
  }
}

# resource "aws_kinesis_firehose_delivery_stream" "logs" {
#   for_each = { for k, v in local.common_delivery : k => v if v.create }

#   name        = each.value.name
#   destination = "opensearch"

#   opensearch_configuration {
#     domain_arn = aws_opensearch_domain.logs.arn
#     role_arn   = aws_iam_role.firehose_delivery_role.arn
#     index_name = each.key
#     index_rotation_period = "OneWeek"

#     s3_configuration {
#       role_arn           = aws_iam_role.firehose_delivery_role.arn
#       bucket_arn         = module.firehose_delivery_logs.s3_bucket_arn
#       buffering_size     = 10
#       buffering_interval = 60
#       compression_format = "GZIP"
#     }

#     cloudwatch_logging_options {
#       enabled         = true
#       log_group_name  = "/aws/kinesisfirehose/${each.key}"
#       log_stream_name = "DestinationDelivery"
#     }

// データの配信前に処理が必要な場合は設定する。
# processing_configuration {
#   enabled = "true"

#   processors {
#     type = "Lambda"

#     parameters {
#       parameter_name  = "LambdaArn"
#       parameter_value = "${aws_lambda_function.lambda_processor.arn}:$LATEST"
#     }
#   }
# }
#   }
# }

#####################################################
# OpenSearch
#####################################################
# resource "aws_opensearch_domain" "logs" {
#   domain_name = "firehose-os-test"
# }

#####################################################
# Athena
#####################################################
/**
 * VPC FlowLogs
 */
resource "aws_athena_workgroup" "forwarding_flow_logs_stats_s3" {
  name          = "forwarding-vpc-flow-log-${local.env_yml.env}"
  description   = "Querying VPC Flow Logs for a Product's Accounts"
  state         = "ENABLED"
  force_destroy = true // 一時的な検証用のため。

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${data.terraform_remote_state.development_storage.outputs.s3_bucket_id_athena_query_result}/output/"

      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }
}

resource "aws_glue_catalog_database" "vpc_flow_logs" {
  name = "vpc_flow_logs_glue_database"
}

resource "aws_glue_crawler" "vpc_flow_logs" {
  name          = aws_glue_catalog_database.vpc_flow_logs.id
  role          = data.terraform_remote_state.development_security.outputs.iam_role_arn_glue_crawler_vpc_flow_logs
  database_name = aws_glue_catalog_database.vpc_flow_logs.id
  schedule      = "cron(0 0 * * ? *)"

  schema_change_policy {
    delete_behavior = "DELETE_FROM_DATABASE"
    update_behavior = "UPDATE_IN_DATABASE"
  }

  s3_target {
    path = "s3://${data.terraform_remote_state.development_storage.outputs.s3_bucket_id_vpc_flow_logs}/"
  }

  configuration = <<EOF
    {
      "Version": 1.0,
      "Grouping": {
        "TableGroupingPolicy": "CombineCompatibleSchemas"
      },
      "CrawlerOutput": {
        "Partitions": {
          "AddOrUpdateBehavior": "InheritFromTable"
        },
        "Tables": {
          "AddOrUpdateBehavior": "MergeNewColumns"
        }
      }
    }
  EOF
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

module "sns_notify_chatbot" {
  source  = "terraform-aws-modules/sns/aws"
  version = "6.1.1"

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

resource "awscc_chatbot_slack_channel_configuration" "example" {
  for_each           = { for k, v in local.chatbots : k => v }
  configuration_name = each.key
  iam_role_arn       = data.terraform_remote_state.development_security.outputs.iam_role_arn_chatbot
  guardrail_policies = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]
  slack_channel_id   = each.value.slack_channel_id
  slack_workspace_id = each.value.slack_workspace_id
  logging_level      = "ERROR"
  sns_topic_arns = [
    aws_sns_topic.slack_alert.arn,
    module.sns_notify_chatbot.topic_arn
  ]
  user_role_required = true

  tags = [
    {
      key   = "Name"
      value = each.key
    }
  ]
}
