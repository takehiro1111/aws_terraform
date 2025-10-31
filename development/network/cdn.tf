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

# resource "aws_cloudfront_vpc_origin" "cdn_takehiro1111_com" {
#   vpc_origin_endpoint_config {
#     name                   = replace(module.value.cdn_takehiro1111_com, ".", "-")
#     arn                    = module.alb_wildcard_takehiro1111_com.arn
#     http_port              = 80
#     https_port             = 443
#     origin_protocol_policy = "https-only"

#     origin_ssl_protocols {
#       items    = ["TLSv1.2"]
#       quantity = length(toset(["TLSv1.2"]))
#     }
#   }
# }

// ref: https://registry.terraform.io/modules/terraform-aws-modules/cloudfront/aws/latest
module "cdn_takehiro1111_com" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "5.0.1"

  # aws_cloudfront_origin_access_control
  create_origin_access_control = true
  origin_access_control = {
    oac_takehiro1111_com = {
      description      = module.value.cdn_takehiro1111_com
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }

  # aws_cloudfront_distribution
  create_distribution = true
  aliases             = [module.value.cdn_takehiro1111_com]
  comment             = module.value.cdn_takehiro1111_com
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  # web_acl_id =  WAF作成時にコメントイン予定

  logging_config = {
    bucket          = data.terraform_remote_state.development_storage.outputs.s3_bucket_domain_name_cdn_access_log
    prefix          = replace(module.value.cdn_takehiro1111_com, ".", "-")
    include_cookies = false
  }

  create_vpc_origin = false

  origin = {
    # origin_alb = {
    #   domain_name = module.alb_wildcard_takehiro1111_com.dns_name
    #   origin_id   = "test-alb-origin"

    #   vpc_origin_config = {
    #     vpc_origin_id            = aws_cloudfront_vpc_origin.cdn_takehiro1111_com.id
    #     origin_keepalive_timeout = 5
    #     origin_read_timeout      = 30
    #   }

    #   # custom_origin_config = {
    #   #   http_port                = 80
    #   #   https_port               = 443
    #   #   origin_protocol_policy   = "https-only"
    #   #   origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    #   #   origin_keepalive_timeout = 5
    #   #   origin_read_timeout      = 20
    #   # }
    # }
    origin_s3 = {
      domain_name           = data.terraform_remote_state.development_storage.outputs.s3_bucket_regional_domain_name_static_site_web
      origin_id             = data.terraform_remote_state.development_storage.outputs.s3_bucket_regional_domain_name_static_site_web
      origin_access_control = module.cdn_takehiro1111_com.cloudfront_origin_access_controls.oac_takehiro1111_com.name

      origin_shield = {
        enabled              = true
        origin_shield_region = data.aws_region.default.name
      }
    }
  }

  # default_cache_behavior = {
  #   target_origin_id       = "test-alb-origin"
  #   viewer_protocol_policy = "allow-all"
  #   allowed_methods        = ["GET", "HEAD", "PUT", "POST", "OPTIONS", "PATCH", "DELETE"]
  #   cached_methods         = ["GET", "HEAD"]
  #   compress               = true
  #   use_forwarded_values   = false

  #   cache_policy_id          = data.aws_cloudfront_cache_policy.managed_caching_disabled.id
  #   origin_request_policy_id = data.aws_cloudfront_origin_request_policy.managed_allviewer.id
  #   # response_headers_policy_id = data.aws_cloudfront_response_headers_policy.security_headers.id

  #   min_ttl     = 0
  #   default_ttl = 0
  #   max_ttl     = 0
  # }

  default_cache_behavior = {
    target_origin_id       = data.terraform_remote_state.development_storage.outputs.s3_bucket_regional_domain_name_static_site_web
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = false
    viewer_protocol_policy = "redirect-to-https"
    use_forwarded_values   = false
    cache_policy_id        = data.aws_cloudfront_cache_policy.managed_caching_optimized.id
  }

  # ordered_cache_behavior = [
  #   {
  #     target_origin_id       = data.terraform_remote_state.development_storage.outputs.s3_bucket_regional_domain_name_static_site_web
  #     path_pattern           = "/static/*"
  #     allowed_methods        = ["GET", "HEAD"]
  #     cached_methods         = ["GET", "HEAD"]
  #     compress               = false
  #     viewer_protocol_policy = "redirect-to-https"
  #     use_forwarded_values   = false
  #     cache_policy_id        = data.aws_cloudfront_cache_policy.managed_caching_optimized.id
  #   }
  # ]

  viewer_certificate = {
    acm_certificate_arn            = module.acm_takehiro1111_com_us_east_1.acm_certificate_arn
    cloudfront_default_certificate = "false"
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }

  custom_error_response = concat(local.custom_error_responses, local.conditional_custom_error_responses)

  geo_restriction = {
    restriction_type = "none"
  }

  tags = {
    Name = module.value.cdn_takehiro1111_com
  }
}

/* 
 * promehteus.takehiro1111.com
 */
# ref: https://registry.terraform.io/modules/terraform-aws-modules/cloudfront/aws/latest
# module "cloudfront_prometheus_takehiro1111_com" {
#   source  = "terraform-aws-modules/cloudfront/aws"
#   version = "4.1.0"

#   # aws_cloudfront_origin_access_control
#   create_origin_access_control = false

#   # aws_cloudfront_distribution
#   create_distribution = true
#   aliases             = [module.value.prometheus_takehiro1111_com]
#   comment             = module.value.prometheus_takehiro1111_com
#   enabled             = true
#   is_ipv6_enabled     = true
#   price_class         = "PriceClass_All"
#   retain_on_delete    = false
#   # web_acl_id =  WAF作成時にコメントイン予定

#   logging_config = {
#     bucket          = data.terraform_remote_state.development_storage.outputs.s3_bucket_domain_name_cdn_access_log
#     prefix          = replace(module.value.prometheus_takehiro1111_com, ".", "-")
#     include_cookies = false
#   }

#   // ALB
#   origin = {
#     origin_alb = {
#       domain_name = module.alb_wildcard_takehiro1111_com.dns_name
#       origin_id   = module.alb_wildcard_takehiro1111_com.dns_name
#       vpc_origin_config = {
#         vpc_origin_id            = aws_cloudfront_vpc_origin.alb.id
#         origin_keepalive_timeout = 10
#         origin_read_timeout      = 30
#       }

#       # custom_origin_config = {
#       #   http_port                = 80
#       #   https_port               = 443
#       #   origin_protocol_policy   = "https-only"
#       #   origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
#       #   origin_keepalive_timeout = 5
#       #   origin_read_timeout      = 20
#       # }
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
#   }

#   viewer_certificate = {
#     acm_certificate_arn            = module.acm_takehiro1111_com_us_east_1.acm_certificate_arn
#     cloudfront_default_certificate = "false"
#     minimum_protocol_version       = "TLSv1.2_2021"
#     ssl_support_method             = "sni-only"
#   }

#   geo_restriction = {
#     restriction_type = "none"
#   }

#   tags = {
#     Name = module.value.prometheus_takehiro1111_com
#   }
# }

# /* 
#  * grafana.takehiro1111.com
#  */
# # ref: https://registry.terraform.io/modules/terraform-aws-modules/cloudfront/aws/latest
# module "cloudfront_grafana_takehiro1111_com" {
#   source  = "terraform-aws-modules/cloudfront/aws"
#   version = "4.1.0"

#   # aws_cloudfront_origin_access_control
#   create_origin_access_control = false

#   # aws_cloudfront_distribution
#   create_distribution = true
#   aliases             = [module.value.grafana_takehiro1111_com]
#   comment             = module.value.grafana_takehiro1111_com
#   enabled             = true
#   is_ipv6_enabled     = true
#   price_class         = "PriceClass_All"
#   retain_on_delete    = false
#   # web_acl_id =  WAF作成時にコメントイン予定

#   logging_config = {
#     bucket          = data.terraform_remote_state.development_storage.outputs.s3_bucket_domain_name_cdn_access_log
#     prefix          = replace(module.value.grafana_takehiro1111_com, ".", "-")
#     include_cookies = false
#   }

#   // ALB
#   origin = {
#     origin_alb = {
#       domain_name = module.alb_wildcard_takehiro1111_com.dns_name
#       origin_id   = module.alb_wildcard_takehiro1111_com.dns_name
#       vpc_origin_config = {
#         vpc_origin_id            = aws_cloudfront_vpc_origin.alb.id
#         origin_keepalive_timeout = 10
#         origin_read_timeout      = 30
#       }

#       # custom_origin_config = {
#       #   http_port                = 80
#       #   https_port               = 443
#       #   origin_protocol_policy   = "https-only"
#       #   origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
#       #   origin_keepalive_timeout = 5
#       #   origin_read_timeout      = 20
#       # }
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
#   }

#   viewer_certificate = {
#     acm_certificate_arn            = module.acm_takehiro1111_com_us_east_1.acm_certificate_arn
#     cloudfront_default_certificate = "false"
#     minimum_protocol_version       = "TLSv1.2_2021"
#     ssl_support_method             = "sni-only"
#   }

#   geo_restriction = {
#     restriction_type = "none"
#   }

#   tags = {
#     Name = module.value.grafana_takehiro1111_com
#   }
# }

# /* 
#  * locust.takehiro1111.com
#  */
# # ref: https://registry.terraform.io/modules/terraform-aws-modules/cloudfront/aws/latest
# module "cloudfront_locust_takehiro1111_com" {
#   source  = "terraform-aws-modules/cloudfront/aws"
#   version = "4.1.0"

#   # aws_cloudfront_origin_access_control
#   create_origin_access_control = false

#   # aws_cloudfront_distribution
#   create_distribution = true
#   aliases             = [module.value.locust_takehiro1111_com]
#   comment             = module.value.locust_takehiro1111_com
#   enabled             = true
#   is_ipv6_enabled     = true
#   price_class         = "PriceClass_All"
#   retain_on_delete    = false
#   # web_acl_id =  WAF作成時にコメントイン予定

#   logging_config = {
#     bucket          = data.terraform_remote_state.development_storage.outputs.s3_bucket_domain_name_cdn_access_log
#     prefix          = replace(module.value.locust_takehiro1111_com, ".", "-")
#     include_cookies = false
#   }

#   // ALB
#   origin = {
#     origin_alb = {
#       domain_name = module.alb_wildcard_takehiro1111_com.dns_name
#       origin_id   = module.alb_wildcard_takehiro1111_com.dns_name
#       vpc_origin_config = {
#         vpc_origin_id            = aws_cloudfront_vpc_origin.alb.id
#         origin_keepalive_timeout = 10
#         origin_read_timeout      = 30
#       }

#       #  custom_origin_config = {
#       #   http_port                = 80
#       #   https_port               = 443
#       #   origin_protocol_policy   = "https-only"
#       #   origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
#       #   origin_keepalive_timeout = 5
#       #   origin_read_timeout      = 20
#       # }
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
#   }

#   viewer_certificate = {
#     acm_certificate_arn            = module.acm_takehiro1111_com_us_east_1.acm_certificate_arn
#     cloudfront_default_certificate = "false"
#     minimum_protocol_version       = "TLSv1.2_2021"
#     ssl_support_method             = "sni-only"
#   }

#   geo_restriction = {
#     restriction_type = "none"
#   }

#   tags = {
#     Name = module.value.locust_takehiro1111_com
#   }
# }



# ref: https://registry.terraform.io/modules/terraform-aws-modules/cloudfront/aws/latest
# module "cloudfront_api_takehiro1111_com" {
#   source  = "terraform-aws-modules/cloudfront/aws"
#   version = "4.0.0"

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

/* 
 * func.takehiro1111.com
 */
resource "aws_cloudfront_function" "url_redirect" {
  name    = "url_redirect"
  runtime = "cloudfront-js-2.0"
  comment = "Appends func to request URLs cdn"
  publish = true
  code    = file("../shared/function/redirect.js")
}

# ref: https://registry.terraform.io/modules/terraform-aws-modules/cloudfront/aws/latest
module "cloudfront_func_takehiro1111_com" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "5.0.1"

  # aws_cloudfront_origin_access_control
  create_origin_access_control = true
  origin_access_control = {
    oac_func_takehiro1111_com = {
      description      = module.value.func_takehiro1111_com
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }

  # aws_cloudfront_distribution
  create_distribution = true
  aliases             = [module.value.func_takehiro1111_com]
  comment             = module.value.func_takehiro1111_com
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false

  logging_config = {
    bucket          = data.terraform_remote_state.development_storage.outputs.s3_bucket_domain_name_cdn_access_log
    prefix          = replace(module.value.func_takehiro1111_com, ".", "-")
    include_cookies = false
  }

  origin = {
    origin_s3 = {
      domain_name           = data.terraform_remote_state.development_storage.outputs.s3_bucket_regional_domain_name_static_site_web
      origin_id             = data.terraform_remote_state.development_storage.outputs.s3_bucket_regional_domain_name_static_site_web
      origin_access_control = module.cloudfront_func_takehiro1111_com.cloudfront_origin_access_controls.oac_func_takehiro1111_com.name

      # origin_shield = {
      #   enabled              = true
      #   origin_shield_region = data.aws_region.default.name
      # }
    }
  }

  default_cache_behavior = {
    target_origin_id       = data.terraform_remote_state.development_storage.outputs.s3_bucket_regional_domain_name_static_site_web
    path_pattern           = "/static/*"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = false
    viewer_protocol_policy = "redirect-to-https"
    use_forwarded_values   = false
    cache_policy_id        = data.aws_cloudfront_cache_policy.managed_caching_optimized.id
    function_association = {
      viewer-request = {
        function_arn = aws_cloudfront_function.url_redirect.arn
      }
    }
  }

  viewer_certificate = {
    acm_certificate_arn            = module.acm_takehiro1111_com_us_east_1.acm_certificate_arn
    cloudfront_default_certificate = "false"
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }

  geo_restriction = {
    restriction_type = "none"
  }

  tags = {
    Name = module.value.func_takehiro1111_com
  }
}

###########################################################################################
# Cloudfront Log For V2
###########################################################################################
# module "cloudfront_log_v2" {
#   source = "../../modules/cloudfront-log-v2"
#   providers = {
#     aws   = aws.us-east-1
#     awscc = awscc.us-east-1
#   }

#   delivery_destination_arn = data.terraform_remote_state.stats_stg.outputs.aws_cloudwatch_log_delivery_destination_for_cloudfront_arn["kidsna-travel"]

#   cloudfront_distributions = [
#     {
#       name         = "stg_travel_kidsna_com"
#       resource_arn = aws_cloudfront_distribution..arn
#     }
#   ]
# }
