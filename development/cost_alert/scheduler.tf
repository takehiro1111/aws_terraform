#####################################################
# EventBridge Scheduler（毎週月曜 09:00 JST）
#####################################################
resource "aws_scheduler_schedule" "alert" {
  name                         = local.name
  schedule_expression          = local.schedule_cron
  schedule_expression_timezone = local.schedule_timezone

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = aws_lambda_function.alert.arn
    role_arn = aws_iam_role.scheduler.arn
  }
}
