output "vpc_id_development" {
  description = "The ID of the development VPC"
  value = module.vpc_development.vpc_id
}

// 作成次第でコメントイン予定(2024/11/10)
# output "cloudfront_arn_cdn_takehiro1111_com" {
#   description = "The ARN of the development CloudFront"
#   value = module.cdn_takehiro1111_com.cloudfront_distribution_arn
# }
