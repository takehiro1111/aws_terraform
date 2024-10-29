output "sso_arn" {
  value = tolist(data.aws_ssoadmin_instances.takehiro1111.arns)[0]
}

output "sso_identity_store_id" {
  value = tolist(data.aws_ssoadmin_instances.takehiro1111.identity_store_ids)[0]
}
