/**
 * ## Description
 *
 * Lambdaのアラート通知を設定する。
 * Cloudwatch LogsへのSubscription Filterの設定と、Cloudwatch AlarmによるSNS通知を設定する。
 *
 *
 * ## Usage:
 * Lambda名称とfilter-patternのMapを設定した変数を指定する。
 *
 * ```hcl
 * lambda =  {"prod__salesforce-v2__sync-register" : { "filter-pattern" : "?ERROR ?Exception" },
 *
 * module alert {
 *   source = "../../modules/lambda/cloudwatch/lambda-alarm/"
 *   param = var.lambda
 *   sns   = aws_sns_topic.cloudwatch_alert_notification.arn
 * }
 * ```
 *
 *}
 */
resource "aws_cloudwatch_metric_alarm" "this" {
  for_each = var.param

  actions_enabled = true

  alarm_description   = "Lambda error metric: Failed  GreaterThanOrEqualToThreshold 1"
  alarm_actions       = [var.sns_arn]
  alarm_name          = each.key
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 1
  dimensions = {
    "FunctionName" = each.key
  }

  evaluation_periods = 1

  metric_name        = "Errors"
  namespace          = "AWS/Lambda"
  period             = 300
  statistic          = "Average"
  threshold          = 1
  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_log_subscription_filter" "this" {
  for_each        = var.param
  log_group_name  = "/aws/lambda/${each.key}"
  name            = "/aws/lambda/${each.key}"
  filter_pattern  = each.value.filter-pattern
  destination_arn = var.destination
  distribution    = "ByLogStream"
  role_arn        = var.role_arn
}
