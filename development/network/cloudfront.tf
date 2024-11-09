#####################################################
# CloudFront
#####################################################
data "aws_cloudfront_cache_policy" "managed_caching_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_cache_policy" "managed_caching_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "managed_allviewer" {
  name = "Managed-AllViewer"
}

data "aws_cloudfront_response_headers_policy" "security_headers" {
  name = "Managed-SecurityHeadersPolicy"
}

# module "cdn_takehiro1111_com" {
#   source  = "terraform-aws-modules/cloudfront/aws"
#   version = "3.4.1"

#   # aws_cloudfront_origin_access_control
#   create_origin_access_control = true
#   origin_access_control = {
#     oac_takehiro1111_com = {
#       description      = module.value.cdn_takehiro1111_com
#       origin_type      = "s3"
#       signing_behavior = "always"
#       signing_protocol = "sigv4"
#     }
#   }

#   # aws_cloudfront_distribution
#   create_distribution = true
#   aliases             = [module.value.cdn_takehiro1111_com]
#   comment             = "common"
#   enabled             = true
#   is_ipv6_enabled     = true
#   price_class         = "PriceClass_All"
#   retain_on_delete    = false
#   # web_acl_id =  WAF作成時にコメントイン予定

#   logging_config = {
#     bucket          = data.terraform_remote_state.development_storage.outputs.s3_bucket_id_cdn_access_log
#     prefix          = local.logging_config_prefix
#     include_cookies = false
#   }

#   // ALB
#   origin = {
#     origin_alb = {
#       domain_name = module.alb_wildcard_takehiro1111_com.dns_name
#       origin_id   = module.alb_wildcard_takehiro1111_com.dns_name

#       custom_origin_config = {
#         http_port                = 80
#         https_port               = 443
#         origin_protocol_policy   = "https-only"
#         origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
#         origin_keepalive_timeout = 5
#         origin_read_timeout      = 20
#       }
#     },

#     origin_s3 = {
#       domain_name           = data.terraform_remote_state.development_storage.outputs.s3_bucket_regional_domain_name_static_site_web
#       origin_id             = data.terraform_remote_state.development_storage.outputs.s3_bucket_regional_domain_name_static_site_web
#       origin_access_control = module.cdn_takehiro1111_com.cloudfront_origin_access_controls.oac_takehiro1111_com.name

#       origin_shield = {
#         enabled              = true
#         origin_shield_region = data.aws_region.default.name
#       }
#     }
#   }

#   default_cache_behavior = {
#     target_origin_id       = module.alb_wildcard_takehiro1111_com.dns_name
#     viewer_protocol_policy = "redirect-to-https"
#     allowed_methods        = ["GET", "HEAD", "PUT", "POST", "OPTIONS", "PATCH", "DELETE"]
#     cached_methods         = ["GET", "HEAD"]
#     compress               = true
#     use_forwarded_values   = false

#     cache_policy_id            = data.aws_cloudfront_cache_policy.managed_caching_disabled.id
#     origin_request_policy_id   = data.aws_cloudfront_origin_request_policy.managed_allviewer.id
#     response_headers_policy_id = data.aws_cloudfront_response_headers_policy.security_headers.id

#     min_ttl     = 0
#     default_ttl = 0
#     max_ttl     = 0
#   }

#   ordered_cache_behavior = [
#     {
#       target_origin_id       = data.terraform_remote_state.development_storage.outputs.s3_bucket_id_static_site_web
#       path_pattern           = "/static/*"
#       allowed_methods        = ["GET", "HEAD"]
#       cached_methods         = ["GET", "HEAD"]
#       compress               = false
#       viewer_protocol_policy = "redirect-to-https"
#       use_forwarded_values   = false
#       cache_policy_id        = data.aws_cloudfront_cache_policy.managed_caching_optimized.id
#     }
#   ]

#   viewer_certificate = {
#     acm_certificate_arn            = module.acm_takehiro1111_com_us_east_1.acm_certificate_arn
#     cloudfront_default_certificate = "false"
#     minimum_protocol_version       = "TLSv1.2_2021"
#     ssl_support_method             = "sni-only"
#   }

#   custom_error_response = concat(local.custom_error_responses, local.conditional_custom_error_responses)

#   geo_restriction = {
#     restriction_type = "none"
#   }

#   tags = {
#     Name = module.value.cdn_takehiro1111_com
#   }
# }

# ref: https://registry.terraform.io/modules/terraform-aws-modules/cloudfront/aws/latest
# module "cloudfront_api_takehiro1111_com" {
#   source  = "terraform-aws-modules/cloudfront/aws"
#   version = "3.4.1"

#   # aws_cloudfront_origin_access_control
#   create_origin_access_control = false

#   # aws_cloudfront_distribution
#   create_distribution = true
#   aliases             = [module.value.api_takehiro1111_com]
#   comment             = "common"
#   enabled             = true
#   is_ipv6_enabled     = true
#   price_class         = "PriceClass_All"
#   retain_on_delete    = false
#   # web_acl_id =  WAF作成時にコメントイン予定

#   logging_config = {
#     bucket          = data.terraform_remote_state.development_storage.outputs.s3_bucket_id_dn_access_log
#     prefix          = local.logging_config_prefix
#     include_cookies = false
#   }

#   // API GW
#   origin = {
#     origin_api_gw = {
#       domain_name = "ezwfdyn08k.execute-api.ap-northeast-1.amazonaws.com"
#       origin_id   = "API-Gateway-Origin"
#       origin_path = "/stg"

#       custom_origin_config = {
#         http_port                = 80
#         https_port               = 443
#         origin_protocol_policy   = "https-only"
#         origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
#         origin_keepalive_timeout = 5
#         origin_read_timeout      = 20
#       }
#     }
#   }

#   default_cache_behavior = {
#     target_origin_id       = "API-Gateway-Origin"
#     viewer_protocol_policy = "https-only"
#     allowed_methods        = ["GET", "HEAD", "PUT", "POST", "OPTIONS", "PATCH", "DELETE"]
#     compress               = false // WebSocketでの通信のため圧縮しない
#     use_forwarded_values   = true
#     query_string = false
#     headers      = ["Authorization"]
#     cookies_forward = "none"
#     min_ttl     = 0
#     default_ttl = 0
#     max_ttl     = 0
#   }

#   viewer_certificate = {
#     acm_certificate_arn            = module.acm_takehiro1111_com_us_east_1.acm_certificate_arn
#     cloudfront_default_certificate = "false"
#     minimum_protocol_version       = "TLSv1.2_2021"
#     ssl_support_method             = "sni-only"
#   }

#   # custom_error_response = concat(local.custom_error_responses, local.conditional_custom_error_responses)

#   geo_restriction = {
#     restriction_type = "none"
#   }

#   tags = {
#     Name = module.value.api_takehiro1111_com
#   }
# }
