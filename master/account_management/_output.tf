output "sso_arn" {
  value = tolist(data.aws_ssoadmin_instances.sso.arns)[0]
}

output "sso_identity_store_id" {
  value = tolist(data.aws_ssoadmin_instances.sso.identity_store_ids)[0]
}

output "cloudtrail_arn" {
  value = module.aws_cloudtrail_ap_northeast_1.cloudtrail_arn
}

output "org_id" {
  value     = data.aws_ssm_parameter.org_id.value
  sensitive = true
}

output "slack_workspace_id" {
  value     = data.aws_ssm_parameter.slack_workspace_id.value
  sensitive = true
}

output "slack_channel_id_aws_alert" {
  value     = data.aws_ssm_parameter.slack_channel_id_aws_alert.value
  sensitive = true
}

output "my_gmail_address" {
  value     = data.aws_ssm_parameter.my_gmail_address.value
  sensitive = true
}

output "my_gmail_alias_address" {
  value     = data.aws_ssm_parameter.my_gmail_alias_address.value
  sensitive = true
}

output "company_mail_address" {
  value     = data.aws_ssm_parameter.company_mail_address.value
  sensitive = true
}
