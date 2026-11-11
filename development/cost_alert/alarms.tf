#####################################################
# Lambda Errors アラーム → SNS → Chatbot
#####################################################
#trivy:ignore:avd-aws-0095 //(HIGH): Topic does not have encryption enabled.
resource "aws_sns_topic" "alarms" {
  name = "${local.name}-alarms"
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${local.name}-lambda-errors"
  alarm_description   = "${local.name} Lambda で 1 週間に 1 回以上のエラー（週次コスト増加の通知が届かない）"
  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  statistic           = "Sum"
  period              = 86400
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"
  dimensions = {
    FunctionName = aws_lambda_function.alert.function_name
  }
  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]
}
