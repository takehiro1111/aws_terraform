######################################################################
# VPC
######################################################################
output "vpc_id_development" {
  description = "The ID of the development VPC"
  value       = module.vpc_development.vpc_id
}

output "private_subnets_id_development" {
  description = "The IDs of the development Subnets"
  value       = module.vpc_development.private_subnets
}

output "public_subnets_id_development" {
  description = "The IDs of the development Subnets"
  value       = module.vpc_development.public_subnets
}

output "private_subnet_a_development" {
  description = "The IDs of the development Subnets"
  value       = element(module.vpc_development.private_subnets, 0)
}

output "public_subnet_a_development" {
  description = "The IDs of the development Subnets"
  value       = element(module.vpc_development.public_subnets, 0)
}

######################################################################
# CloudFront
######################################################################
# output "cloudfront_arn_cdn_takehiro1111_com" {
#   description = "The ARN of the development CloudFront"
#   value       = module.cdn_takehiro1111_com.cloudfront_distribution_arn
# }

######################################################################
# ALB
######################################################################
output "target_group_arn_web" {
  description = "The ARN of the development ALB Target Group"
  value       = aws_lb_target_group.web.arn
}

output "target_group_arn_locust" {
  description = "The ARN of the development ALB Target Group"
  value       = aws_lb_target_group.locust.arn
}


# output "target_group_arn_ec2_promehteus_server" {
#   description = "The ARN of the development ALB Target Group"
#   value       = aws_lb_target_group.prometheus_server.arn
# }
