output "sso_arn" {
  value = tolist(data.aws_ssoadmin_instances.sso.arns)[0]
}

output "sso_identity_store_id" {
  value = tolist(data.aws_ssoadmin_instances.sso.identity_store_ids)[0]
}
