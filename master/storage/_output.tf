##########################################################
# S3 Bucket
##########################################################
output "s3_bucket_arn_config_audit_log" {
  description = "Config S3Bucket"
  value       = module.s3_bucket_config_audit_log.s3_bucket_arn
}

output "s3_bucket_id_config_audit_log" {
  description = "Config S3Bucket"
  value       = module.s3_bucket_config_audit_log.s3_bucket_id
}
