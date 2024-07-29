#####################################################
# Cloudwatch Logs
#####################################################
# ECS -----------------------------------------
resource "aws_cloudwatch_log_group" "stg" {
  retention_in_days = 7
  name              = "/ecslogs/stg"
  kms_key_id        = aws_kms_key.cloudwatch_logs.arn
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
resource "aws_cloudwatch_event_rule" "update_waf_rule" {
  name        = "update_waf_rule"
  description = "Trigger Lambda function on UpdateWebACL for specific WAF rule"

  event_pattern = jsonencode({
    source = ["aws.waf"],
    detail-type =  ["AWS API Call via CloudTrail"],
    detail =  {
      eventSource = ["waf.amazonaws.com"],
      eventName = ["UpdateWebACL"],
      requestParameters =  {
        rules = {
          name = ["CountOtherRegions"]
        }
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.update_waf_rule.name
  target_id = "update_waf_rule_lambda"
  arn       = aws_lambda_function.update_waf_rule.arn
}


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
