#####################################################
# Cloudwatch Logs
#####################################################
# ECS -----------------------------------------
#trivy:ignore:avd-aws-0017 // (LOW): Log group is not encrypted.
resource "aws_cloudwatch_log_group" "ecs_nginx" {
  retention_in_days = 1
  name              = "/ecslogs/nginx"
}

#trivy:ignore:avd-aws-0017 // (LOW): Log group is not encrypted.
resource "aws_cloudwatch_log_group" "ecs_locust" {
  retention_in_days = 1
  name              = "ecslogs/locust"
}

#trivy:ignore:avd-aws-0017 // (LOW): Log group is not encrypted.
resource "aws_cloudwatch_log_group" "events_app_autoscaling" {
  retention_in_days = 3
  name              = "/aws/events/ecs/autoscaling"
}

# EC2 ------------------------------------------
#trivy:ignore:avd-aws-0017 // (LOW): Log group is not encrypted.
resource "aws_cloudwatch_log_group" "public_instance" {
  name              = "/compute/ec2/public"
  log_group_class   = "STANDARD"
  skip_destroy      = true
  retention_in_days = 1
}

# VPCフローログ --------------------------------
#trivy:ignore:avd-aws-0017 // (LOW): Log group is not encrypted.
resource "aws_cloudwatch_log_group" "flow_log" {
  name              = "/vpc/flow-log"
  log_group_class   = "STANDARD"
  skip_destroy      = true
  retention_in_days = 1
}

# Lambda --------------------------------
#trivy:ignore:avd-aws-0017 // (LOW): Log group is not encrypted.
resource "aws_cloudwatch_log_group" "lambda_s3_create" {
  name              = "/lambda/s3-create"
  log_group_class   = "STANDARD"
  skip_destroy      = true
  retention_in_days = 1
}

#####################################################
# Athena
#####################################################
/**
 * VPC FlowLogs
 */
# resource "aws_athena_workgroup" "forwarding_flow_logs_stats_s3" {
#   name          = "forwarding-vpc-flow-log-${local.env_yml.env}"
#   description   = "Querying VPC Flow Logs for a Product's Accounts"
#   state         = "ENABLED"
#   force_destroy = true // 一時的な検証用のため。

#   configuration {
#     enforce_workgroup_configuration    = true
#     publish_cloudwatch_metrics_enabled = true

#     result_configuration {
#       output_location = "s3://${data.terraform_remote_state.development_storage.outputs.s3_bucket_id_athena_query_result}/output/"

#       encryption_configuration {
#         encryption_option = "SSE_S3"
#       }
#     }
#   }
# }

# resource "aws_glue_catalog_database" "vpc_flow_logs" {
#   name = "vpc_flow_logs_glue_database"
# }

# resource "aws_glue_crawler" "vpc_flow_logs" {
#   name          = aws_glue_catalog_database.vpc_flow_logs.id
#   role          = data.terraform_remote_state.development_security.outputs.iam_role_arn_glue_crawler_vpc_flow_logs
#   database_name = aws_glue_catalog_database.vpc_flow_logs.id
#   schedule      = "cron(0 0 * * ? *)"

#   schema_change_policy {
#     delete_behavior = "DELETE_FROM_DATABASE"
#     update_behavior = "UPDATE_IN_DATABASE"
#   }

#   s3_target {
#     path = "s3://${data.terraform_remote_state.development_storage.outputs.s3_bucket_id_vpc_flow_logs}/"
#   }

#   configuration = <<EOF
#     {
#       "Version": 1.0,
#       "Grouping": {
#         "TableGroupingPolicy": "CombineCompatibleSchemas"
#       },
#       "CrawlerOutput": {
#         "Partitions": {
#           "AddOrUpdateBehavior": "InheritFromTable"
#         },
#         "Tables": {
#           "AddOrUpdateBehavior": "MergeNewColumns"
#         }
#       }
#     }
#   EOF
# }

#####################################################
# Kinesis Data Firehose
#####################################################
# locals {
#   common_delivery = {
#     common_vpc_flow_logs = {
#       create     = true
#       name       = "delivery-vpc-flow-logs"
#       index_name = "comon_vpc_flow_logs"
#     }
#   }
# }

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
