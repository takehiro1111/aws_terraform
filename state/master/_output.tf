output "account_id" {
  description = "ステートファイルを置いているAWSアカウントID"
  value       = data.aws_caller_identity.self.account_id
}

output "s3_bucket_id_tfstate" {
  description = "ステートファイルが配置されているS3バケットのName"
  value       = module.s3_bucket_tfstate.s3_bucket_id
}

output "s3_bucket_arn_tfstate" {
  description = "ステートファイルが配置されているS3バケットのARN"
  value       = module.s3_bucket_tfstate.s3_bucket_arn
}
