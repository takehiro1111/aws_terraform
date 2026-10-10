/*
 * all-accounts-cost-alert
 */
locals {
  name = "all-accounts-cost-alert"

  // master/cost_alert_reader/iam.tf のロール名・信頼先と一致させる
  management_account_id = "685339645368"
  reader_role_name      = "all-accounts-cost-alert-reader"

  // development/management/monitor.tf で作成済みの Slack Webhook URL
  slack_webhook_parameter_name = "/app/personal/SLACK_WEBHOOK_URL"

  lambda_src_dir  = "${path.module}/../../function/all_accounts_cost_alert"
  lambda_dist_dir = "${local.lambda_src_dir}/dist"

  increase_ratio_threshold = "0.2"
  increase_usd_threshold   = "1"

  schedule_cron     = "cron(0 9 ? * MON *)"
  schedule_timezone = "Asia/Tokyo"
}
