output "identitystore_group_arn" {
  description = "PermissionSetのARNを参照するための設定"
  value       = { for k, v in aws_identitystore_group.this : k => v.group_id }
}
