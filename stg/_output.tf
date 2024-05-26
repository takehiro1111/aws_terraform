output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "tfstate_sekigaku_arn" {
  value = aws_s3_bucket.tfstate_sekigaku.arn
}

output "tfstate_locks_name" {
  value = aws_dynamodb_table.tfstate_locks.id
}

variable "names" {
  type    = list(string)
  default = ["neo", "trinity", "move"]
}

output "variables_name" {
  value = "%{for v, value in var.names} (${v}) ${value}, %{endfor}"
}

output "aws_ec2_managed_prefix_list_cdn" {
  value = data.aws_ec2_managed_prefix_list.cdn.id
}
