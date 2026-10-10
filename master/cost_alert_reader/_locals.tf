/*
 * Default Tags
 */
locals {
  service_name = "cost_alert_reader"
  repo         = "aws_terraform"
  dir          = "master/cost_alert_reader"
}

/*
 * development アカウントの Lambda 実行ロール（development/cost_alert/iam.tf）と名前を一致させる
 */
locals {
  development_account_id = "650251692423"
  hub_role_name          = "all-accounts-cost-alert"
}
