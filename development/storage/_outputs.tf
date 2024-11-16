######################################################################
# Account ID
######################################################################
output "account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.self.account_id
}

######################################################################
# S3 Bucket ID
######################################################################
output "s3_bucket_id_logging_target" {
  description = "Logging Target S3 Bucket"
  value       = module.s3_bucket_logging_target.s3_bucket_id
}

output "s3_bucket_id_alb_access_log" {
  description = "ALB Access Log S3 Bucket"
  value       = module.s3_bucket_alb_accesslog.s3_bucket_id
}

output "s3_bucket_id_cdn_access_log" {
  description = "CDN Access Log S3 Bucket"
  value       = module.s3_bucket_cdn_accesslog.s3_bucket_id
}

output "s3_bucket_id_static_site_web" {
  description = "Static WebSite S3 Bucket"
  value       = module.s3_bucket_static_site_web.s3_bucket_id
}

output "s3_bucket_id_athena_query_result" {
  description = "Athena Query Result S3 Bucket"
  value       = module.s3_bucket_athena_query_result.s3_bucket_id
}

output "s3_bucket_id_vpc_flow_logs" {
  description = "VPC Flow Logs S3 Bucket"
  value       = module.s3_bucket_vpc_flow_logs.s3_bucket_id
}

######################################################################
# S3 Bucket ARN
######################################################################
output "s3_bucket_arn_static_site_web" {
  description = "Static WebSite S3 Bucket ARN"
  value       = module.s3_bucket_static_site_web.s3_bucket_arn
}

output "s3_bucket_arn_logging_target" {
  description = "ALB Access Log S3 Bucket ARN"
  value       = module.s3_bucket_logging_target.s3_bucket_arn
}

######################################################################
# Regional Domain Name
######################################################################
output "s3_bucket_regional_domain_name_static_site_web" {
  description = "Static WebSite S3 Bucket"
  value       = module.s3_bucket_static_site_web.s3_bucket_bucket_regional_domain_name
}
