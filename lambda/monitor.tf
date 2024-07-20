#####################################################
# Cloudwatch Logs
#####################################################
resource "aws_cloudwatch_log_group" "lambda_hello_world" {
  name              = "/aws/lambda/${aws_lambda_function.hello_world.function_name}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "sns_mail" {
  name              = "/aws/lambda/${aws_lambda_function.sns_mail.function_name}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "s3_create" {
  name              = "/aws/lambda/s3-create"
  retention_in_days = 7
}
