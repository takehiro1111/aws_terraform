output "sso_arn" {
  value = tolist(data.aws_ssoadmin_instances.sso.arns)[0]
}

output "sso_identity_store_id" {
  value = tolist(data.aws_ssoadmin_instances.sso.identity_store_ids)[0]
}

output "cloudtrail_arn" {
  value = module.aws_cloudtrail_ap_northeast_1.cloudtrail_arn
}
