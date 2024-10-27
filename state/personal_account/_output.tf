output "account_id" {
  description = "ステートファイルを置いているAWSアカウントID"
  value       = data.aws_caller_identity.self.account_id
}

output "state_s3_bucket_id" {
  description = "ステートファイルが配置されているS3バケットのname"
  value       = module.s3_bucket_tfstate.s3_bucket_id
}
