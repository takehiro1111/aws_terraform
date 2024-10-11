#####################################################
# Cloudwatch Logs
#####################################################
# ECS -----------------------------------------
resource "aws_cloudwatch_log_group" "ecs_nginx" {
  retention_in_days = 7
  name              = "/ecslogs/nginx"
}

resource "aws_cloudwatch_log_group" "stg_2" {
  retention_in_days = 7
  name              = "/ecslogs/stg-2"
  kms_key_id        = aws_kms_key.cloudwatch_logs.arn
}

# EC2 ------------------------------------------
resource "aws_cloudwatch_log_group" "public_instance" {
  name              = "/compute/ec2/public"
  log_group_class   = "STANDARD"
  skip_destroy      = true
  retention_in_days = 7
}

# VPCフローログ --------------------------------
resource "aws_cloudwatch_log_group" "flow_log" {
  name              = "/vpc/flow-log"
  log_group_class   = "STANDARD" // https://aws.amazon.com/jp/blogs/news/new-amazon-cloudwatch-log-class-for-infrequent-access-logs-at-a-reduced-price/
  skip_destroy      = true
  retention_in_days = 7
}

# fluent-bitのログ収集 ----------------------------
# resource "aws_cloudwatch_log_group" "for_ecs" {
#   name              = "ecs/fluent-bit/test"
#   retention_in_days = 30
# }

#####################################################
# Cloudwatch Alerm
#####################################################

#####################################################
# Parameter Store
#####################################################
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
  name        = "/${local.servicename}/SLACK_WEBHOOK"
  description = "Slack Webhook lambda_notify channel"
  type        = "SecureString"
  value       = "画面上から対応"

  lifecycle {
    ignore_changes = [value]
  }
}
#####################################################
# EventBridge
#####################################################
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
# Athena
#####################################################
# resource "aws_athena_workgroup" "test" {
#   name = aws_s3_bucket.athena.id

#   configuration {
#     enforce_workgroup_configuration    = true
#     publish_cloudwatch_metrics_enabled = false
#     result_configuration {
#       output_location = "s3://${aws_s3_bucket.athena.id}/athena-result/"
#       encryption_configuration {
#         encryption_option = "SSE_S3"
#       }
#     }
#   }
# }

# resource "aws_athena_database" "test" {
#   name   = "test_employee_list"
#   bucket = aws_s3_bucket.athena.id
# }

# data "template_file" "flow_log" {
#   template = file("${path.module}/sql/create-table.sql.tpl")
#   vars = {
#     athena_database_name = var.athena_database_name
#     athena_table_name    = var.athena_table_name
#     log_bucket_name      = var.log_bucket_name
#   }
# }

# resource "aws_athena_named_query" "flow_log" {
#   name        = "Create table"
#   description = "テーブルを作成"
#   workgroup   = aws_athena_workgroup.flow_log.id
#   database    = aws_athena_database.flow_log.id
#   query       = data.template_file.flow_log.rendered
# }

#####################################################
# SNS
#####################################################
resource "aws_sns_topic" "lambda_mail" {
  name = "lambda-mail-sns-topic"
}

resource "aws_sns_topic_subscription" "lambda_mail" {
  topic_arn = aws_sns_topic.lambda_mail.arn
  protocol  = "email"
  endpoint  = module.value.my_gmail_address
}

######################################################################
# Config
######################################################################

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
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
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
  description = each.value.description
  type        = "SecureString"
  value       = "コンソール画面で設定する。"

  lifecycle {
    ignore_changes = [value]
  }
}

######################################################################
# Chatbot
######################################################################
locals {
  chatbots = {
    personal = {
      name               = "common-alert-notify"
      slack_workspace_id = "T06PFGXUB2B" # personal 
      slack_channel_id   = "C07GTL63RDJ" # aws_alert
    }
  }
}

resource "awscc_chatbot_slack_channel_configuration" "example" {
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


/**
 * VPC FlowLogs
 */
resource "aws_athena_workgroup" "forwarding_flow_logs_stats_s3" {
  name          = "forwarding-vpc-flow-log-${local.env}"
  description   = "Querying VPC Flow Logs for a Product's Accounts"
  state         = "ENABLED"
  force_destroy = true // 一時的な検証用のため。

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${module.athena_query_result_for_vpc_flow_log.s3_bucket_id}/output/"

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
  role          = aws_iam_role.glue_crawler_vpc_flow_logs.arn
  database_name = aws_glue_catalog_database.vpc_flow_logs.id
  schedule      = "cron(0 0 * * ? *)"

  schema_change_policy {
    delete_behavior = "DELETE_FROM_DATABASE"
    update_behavior = "UPDATE_IN_DATABASE"
  }

  s3_target {
    path = "s3://${module.s3_for_vpc_flow_log_stg.s3_bucket_id}"
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
