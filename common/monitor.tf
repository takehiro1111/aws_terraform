#=========================================
# CloudWatch Logs
#=========================================
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

# Lambda関数 -----------------------------------
resource "aws_cloudwatch_log_group" "lambda_hello_world" {
  name              = "/aws/lambda/${aws_lambda_function.hello_world.function_name}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "sns_mail" {
  name              = "/aws/lambda/${aws_lambda_function.sns_mail.function_name}"
  retention_in_days = 7
}

#=========================================
# Parameter Group
#=========================================
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

#=========================================
# Athena
#=========================================
resource "aws_athena_workgroup" "test" {
  name = aws_s3_bucket.athena.id

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = false
    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena.id}/athena-result/"
      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }
}

resource "aws_athena_database" "test" {
  name   = "test_employee_list"
  bucket = aws_s3_bucket.athena.id
}

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

#=========================================
# SNS
#=========================================
resource "aws_sns_topic" "lambda_mail" {
  name = "lambda-mail-sns-topic"
}

resource "aws_sns_topic_subscription" "lambda_mail" {
  topic_arn = aws_sns_topic.lambda_mail.arn
  protocol  = "email"
  endpoint  = module.value.my_gmail_address
}

#=========================================
# Lambda Function
#=========================================
resource "aws_lambda_function" "hello_world" {
  function_name    = "hello-world"
  handler          = "hello_world.handler" # ファイル名.関数名
  runtime          = "python3.12"
  memory_size      = 128 # デフォルト
  filename         = data.archive_file.hello_world.output_path
  source_code_hash = filebase64sha256(data.archive_file.hello_world.output_path)
  role             = aws_iam_role.lambda_execute.arn
}

data "archive_file" "hello_world" {
  type        = "zip"
  source_file = "../function/hello_world.py"
  output_path = "../function/archive_zip/lambda_hello_world.zip"
}

resource "aws_lambda_function" "sns_mail" {
  function_name    = "sns-mail"
  handler          = "sns_mail.handler" # ファイル名.関数名
  runtime          = "python3.12"
  memory_size      = 128 # デフォルト
  filename         = data.archive_file.sns_mail.output_path
  source_code_hash = filebase64sha256(data.archive_file.sns_mail.output_path)
  role             = aws_iam_role.lambda_execute.arn
}

data "archive_file" "sns_mail" {
  type        = "zip"
  source_file = "../function/sns_mail.py"
  output_path = "../function/archive_zip/sns_mail.zip"
}

resource "aws_lambda_function" "s3_cp" {
  function_name    = "s3-cp-default"
  handler          = "s3_cp_default.handler" # ファイル名.関数名
  runtime          = "python3.12"
  memory_size      = 128 # デフォルト
  filename         = data.archive_file.sns_mail.output_path
  source_code_hash = filebase64sha256(data.archive_file.sns_mail.output_path)
  role             = aws_iam_role.lambda_execute.arn
}

data "archive_file" "s3_cp" {
  type        = "zip"
  source_file = "../function/s3_cp_default.py"
  output_path = "../function/archive_zip/s3_cp_default.zip"
}
