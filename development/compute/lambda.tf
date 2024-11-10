##################################################################
# Tutorial
##################################################################
// 本運用はSAMでデプロイしている。以下は練習用。
/* 
 * Hello World用
 */
resource "aws_lambda_function" "hello_world" {
  function_name    = "hello-world"
  handler          = "hello_world.handler" # ファイル名.関数名
  runtime          = "python3.12"
  memory_size      = 128 # デフォルト
  filename         = data.archive_file.hello_world.output_path
  source_code_hash = filebase64sha256(data.archive_file.hello_world.output_path)
  role             = data.terraform_remote_state.development_security.outputs.iam_role_arn_lambda_execute
}

data "archive_file" "hello_world" {
  type        = "zip"
  source_file = "../../function/hello_world.py"
  output_path = "../../function/archive_zip/lambda_hello_world.zip"
}


/* 
 * SNSのメール認証用
 */
resource "aws_lambda_function" "sns_mail" {
  function_name    = "sns-mail"
  handler          = "sns_mail.handler" # ファイル名.関数名
  runtime          = "python3.12"
  memory_size      = 128
  filename         = data.archive_file.sns_mail.output_path
  source_code_hash = filebase64sha256(data.archive_file.sns_mail.output_path)
  role             = data.terraform_remote_state.development_security.outputs.iam_role_arn_lambda_execute
}

data "archive_file" "sns_mail" {
  type        = "zip"
  source_file = "../../function/sns_mail.py"
  output_path = "../../function/archive_zip/sns_mail.zip"
}

/* 
 * S3バケットのコピー
 */
resource "aws_lambda_function" "s3_cp" {
  function_name    = "s3-cp-default"
  handler          = "s3_cp_default.handler" # ファイル名.関数名
  runtime          = "python3.12"
  memory_size      = 128
  filename         = data.archive_file.s3_cp.output_path
  source_code_hash = filebase64sha256(data.archive_file.sns_mail.output_path)
  role             = data.terraform_remote_state.development_security.outputs.iam_role_arn_lambda_execute
}

data "archive_file" "s3_cp" {
  type        = "zip"
  source_file = "../../function/s3_cp_default.py"
  output_path = "../../function/archive_zip/s3_cp_default.zip"
}

/* 
 * S3バケット作成
 */
resource "aws_lambda_function" "s3_create" {
  function_name    = "s3-create"
  handler          = "s3_create.create_s3_bucket" # ファイル名.関数名
  runtime          = "python3.12"
  memory_size      = 128
  filename         = data.archive_file.s3_create.output_path
  source_code_hash = filebase64sha256(data.archive_file.s3_create.output_path)
  role             = data.terraform_remote_state.development_security.outputs.iam_role_arn_lambda_execute

  logging_config {
    log_format = "JSON"
    log_group = data.terraform_remote_state.development_management.outputs.cw_log_group_name_lambda_s3_create
    system_log_level = "WARN"
  }
}

data "archive_file" "s3_create" {
  type        = "zip"
  source_file = "../../function/s3_create.py"
  output_path = "../../function/archive_zip/s3_create.zip"
}

