/* 
 * ID
 */
output "s3_bucket_id_alb_access_log" {
  description = "ALB Access Log S3 Bucket"
  value = module.s3_bucket_alb_accesslog.s3_bucket_id
}

output "s3_bucket_id_cdn_access_log" {
  description = "CDN Access Log S3 Bucket"
  value = module.s3_bucket_cdn_accesslog.s3_bucket_id
}

output "s3_bucket_id_static_site_web" {
  description = "Static WebSite S3 Bucket"
  value = module.s3_bucket_static_site_web.s3_bucket_id
}

output "s3_bucket_regional_domain_name_static_site_web" {
  description = "Static WebSite S3 Bucket"
  value = module.s3_bucket_static_site_web.s3_bucket_bucket_regional_domain_name
}

/* 
 * ARN
 */
output "s3_bucket_arn_static_site_web" {
  description = "Static WebSite S3 Bucket ARN"
  value = module.s3_bucket_static_site_web.s3_bucket_arn
}

output "s3_bucket_arn_logging_target" {
  description = "ALB Access Log S3 Bucket ARN"
  value = module.s3_bucket_logging_target.s3_bucket_arn
}
