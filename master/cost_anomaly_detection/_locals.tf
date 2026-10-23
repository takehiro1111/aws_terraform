/*
 * Default Tags
 */
locals {
  service_name = "cost_anomaly_detection"
  repo         = "aws_terraform"
  dir          = "master/cost_anomaly_detection"
}

/*
 * Cost Anomaly Detection
 */
locals {
  name = "cost-anomaly-detection"

  // 期待額に対する増加率（%）がこの値以上の異常だけ Slack に通知する
  anomaly_impact_percentage_threshold = "1"
}
