######################################################################
# VPC
######################################################################

output "vpc_id_development" {
  description = "The ID of the development VPC"
  value = module.vpc_development.vpc_id
}

output "private_subnets_id_development" {
  description = "The IDs of the development Subnets"
  value = module.vpc_development.private_subnets
}

######################################################################
# CloudFront
######################################################################
// 作成次第でコメントイン予定(2024/11/10)
# output "cloudfront_arn_cdn_takehiro1111_com" {
#   description = "The ARN of the development CloudFront"
#   value = module.cdn_takehiro1111_com.cloudfront_distribution_arn
# }

######################################################################
# ALB
######################################################################
output "target_group_arn_web" {
  description = "The ARN of the development ALB Target Group"
  value = aws_lb_target_group.hoge.arn
}
