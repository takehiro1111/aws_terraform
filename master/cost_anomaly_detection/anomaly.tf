#####################################################
# Cost Anomaly Detection
#####################################################
/*
 * AWS managed monitor。Organizations 配下の全メンバーアカウントを個別に監視し、新規アカウントも自動で対象に入る
 */
resource "aws_ce_anomaly_monitor" "linked_accounts" {
  name              = "${local.name}-linked-accounts"
  monitor_type      = "DIMENSIONAL"
  monitor_dimension = "LINKED_ACCOUNT"
}

resource "aws_ce_anomaly_subscription" "slack" {
  name      = "${local.name}-slack"
  frequency = "IMMEDIATE"

  monitor_arn_list = [aws_ce_anomaly_monitor.linked_accounts.arn]

  subscriber {
    type    = "SNS"
    address = aws_sns_topic.anomaly.arn
  }

  threshold_expression {
    dimension {
      key           = "ANOMALY_TOTAL_IMPACT_PERCENTAGE"
      match_options = ["GREATER_THAN_OR_EQUAL"]
      values        = [local.anomaly_impact_percentage_threshold]
    }
  }

  depends_on = [aws_sns_topic_policy.anomaly]
}
