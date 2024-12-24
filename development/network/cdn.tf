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

resource "aws_cloudfront_vpc_origin" "alb" {
  vpc_origin_endpoint_config {
    name                   = "alb-web"
    arn                    = module.alb_wildcard_takehiro1111_com.arn
    http_port              = 80
    https_port             = 443
    origin_protocol_policy = "https-only"

    origin_ssl_protocols {
      items    = ["TLSv1.2"]
      quantity = 1
    }
  }
}





resource "aws_cloudfront_origin_access_control" "this" {
  description                       = "cdn.takehiro1111.com" 
  name                              = "oac_takehiro1111_com" 
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "this" {
    aliases                         = [
        "cdn.takehiro1111.com",
    ]
    comment                         = "cdn.takehiro1111.com"
    enabled                         = true
    is_ipv6_enabled                 = true
    price_class                     = "PriceClass_All"
    retain_on_delete                = false

    custom_error_response {
        error_caching_min_ttl = 10
        error_code            = 500
        response_code         = 500
        response_page_path    = "/maintenance/maintenance.html"
    }
    custom_error_response {
        error_caching_min_ttl = 10
        error_code            = 501
        response_code         = 501
        response_page_path    = "/maintenance/maintenance.html"
    }
    custom_error_response {
        error_caching_min_ttl = 10
        error_code            = 502
        response_code         = 502
        response_page_path    = "/maintenance/maintenance.html"
    }
    custom_error_response {
        error_caching_min_ttl = 10
        error_code            = 504
        response_code         = 504
        response_page_path    = "/maintenance/maintenance.html"
    }

    default_cache_behavior {
        allowed_methods            = [
            "DELETE",
            "GET",
            "HEAD",
            "OPTIONS",
            "PATCH",
            "POST",
            "PUT",
        ]
        cache_policy_id            = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
        cached_methods             = [
            "GET",
            "HEAD",
        ]
        compress                   = true
        default_ttl                = 0
        max_ttl                    = 0
        min_ttl                    = 0
        origin_request_policy_id   = "216adef6-5c7f-47e4-b989-5492eafa07d3"
        target_origin_id           = "internal-development-1279856694.ap-northeast-1.elb.amazonaws.com"
        viewer_protocol_policy     = "allow-all"
    }

    logging_config {
        bucket          = "cdn-log-650251692423.s3.amazonaws.com"
        include_cookies = false
        prefix          = "cdn-takehiro1111-com"
    }

    ordered_cache_behavior {
        allowed_methods            = [
            "GET",
            "HEAD",
        ]
        cache_policy_id            = "658327ea-f89d-4fab-a63d-7e88639e58f6"
        cached_methods             = [
            "GET",
            "HEAD",
        ]
        compress                   = false
        default_ttl                = 0
        max_ttl                    = 0
        min_ttl                    = 0
        path_pattern               = "/static/*"
        target_origin_id           = "static-site-web-650251692423.s3.ap-northeast-1.amazonaws.com"
        viewer_protocol_policy     = "redirect-to-https"
    }

    origin {
        connection_attempts      = 3
        connection_timeout       = 10
        domain_name              = "internal-development-1279856694.ap-northeast-1.elb.amazonaws.com"
        origin_id                = "internal-development-1279856694.ap-northeast-1.elb.amazonaws.com"

        

      vpc_origin_config  {
        vpc_origin_id            = aws_cloudfront_vpc_origin.alb.id
        origin_keepalive_timeout = 5
        origin_read_timeout      = 30
      }

    }
    origin {
        connection_attempts      = 3
        connection_timeout       = 10
        domain_name              = "static-site-web-650251692423.s3.ap-northeast-1.amazonaws.com"
        origin_access_control_id = "E312XNBHM6QQDD"
        origin_id                = "static-site-web-650251692423.s3.ap-northeast-1.amazonaws.com"

        origin_shield {
            enabled              = true
            origin_shield_region = "ap-northeast-1"
        }
    }

    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }

    viewer_certificate {
        acm_certificate_arn            = "arn:aws:acm:us-east-1:650251692423:certificate/33a8920a-bb1d-4f3a-9b0a-f108cabcb882"
        cloudfront_default_certificate = false
        minimum_protocol_version       = "TLSv1.2_2021"
        ssl_support_method             = "sni-only"
    }
}

# ref: https://registry.terraform.io/modules/terraform-aws-modules/cloudfront/aws/latest
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
#   comment             = module.value.cdn_takehiro1111_com
#   enabled             = true
#   is_ipv6_enabled     = true
#   price_class         = "PriceClass_All"
#   retain_on_delete    = false
#   # web_acl_id =  WAF作成時にコメントイン予定

#   logging_config = {
#     bucket          = data.terraform_remote_state.development_storage.outputs.s3_bucket_domain_name_cdn_access_log
#     prefix          = replace(module.value.cdn_takehiro1111_com, ".", "-")
#     include_cookies = false
#   }

#   // ALB
#   origin = {
#     origin_alb = {
#       domain_name = module.alb_wildcard_takehiro1111_com.dns_name
#       origin_id   = module.alb_wildcard_takehiro1111_com.dns_name

#       # custom_origin_config = {
#       #   http_port                = 80
#       #   https_port               = 443
#       #   origin_protocol_policy   = "https-only"
#       #   origin_ssl_protocols     = ["TLSv1.2"]
#       #   origin_keepalive_timeout = 5
#       #   origin_read_timeout      = 20
#       # }

#       vpc_origin_config = {
#         vpc_origin_id            = aws_cloudfront_vpc_origin.alb.id
#         origin_keepalive_timeout = 10
#         origin_read_timeout      = 30
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
#     viewer_protocol_policy = "allow-all"
#     allowed_methods        = ["GET", "HEAD", "PUT", "POST", "OPTIONS", "PATCH", "DELETE"]
#     cached_methods         = ["GET", "HEAD"]
#     compress               = true
#     use_forwarded_values   = false

#     cache_policy_id          = data.aws_cloudfront_cache_policy.managed_caching_disabled.id
#     origin_request_policy_id = data.aws_cloudfront_origin_request_policy.managed_allviewer.id
#     # response_headers_policy_id = data.aws_cloudfront_response_headers_policy.security_headers.id

#     min_ttl     = 0
#     default_ttl = 0
#     max_ttl     = 0
#   }

#   ordered_cache_behavior = [
#     {
#       target_origin_id       = data.terraform_remote_state.development_storage.outputs.s3_bucket_regional_domain_name_static_site_web
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


/* 
 * promehteus.takehiro1111.com
 */
# ref: https://registry.terraform.io/modules/terraform-aws-modules/cloudfront/aws/latest
module "cloudfront_prometheus_takehiro1111_com" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "3.4.1"

  # aws_cloudfront_origin_access_control
  create_origin_access_control = false

  # aws_cloudfront_distribution
  create_distribution = true
  aliases             = [module.value.prometheus_takehiro1111_com]
  comment             = module.value.prometheus_takehiro1111_com
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  # web_acl_id =  WAF作成時にコメントイン予定

  logging_config = {
    bucket          = data.terraform_remote_state.development_storage.outputs.s3_bucket_domain_name_cdn_access_log
    prefix          = replace(module.value.prometheus_takehiro1111_com, ".", "-")
    include_cookies = false
  }


  // ALB
  origin = {
    origin_alb = {
      domain_name = module.alb_wildcard_takehiro1111_com.dns_name
      origin_id   = module.alb_wildcard_takehiro1111_com.dns_name

      vpc_origin_config = {
        vpc_origin_id            = aws_cloudfront_vpc_origin.alb.id
        origin_keepalive_timeout = 10
        origin_read_timeout      = 30
      }

      # custom_origin_config = {
      #   http_port                = 80
      #   https_port               = 443
      #   origin_protocol_policy   = "https-only"
      #   origin_ssl_protocols     = ["TLSv1.2"]
      #   origin_keepalive_timeout = 5
      #   origin_read_timeout      = 20
      # }
    }
  }

  default_cache_behavior = {
    target_origin_id       = module.alb_wildcard_takehiro1111_com.dns_name
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "PUT", "POST", "OPTIONS", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    use_forwarded_values   = false

    cache_policy_id            = data.aws_cloudfront_cache_policy.managed_caching_disabled.id
    origin_request_policy_id   = data.aws_cloudfront_origin_request_policy.managed_allviewer.id
    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.security_headers.id
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
    Name = module.value.prometheus_takehiro1111_com
  }
}

/* 
 * grafana.takehiro1111.com
 */
# ref: https://registry.terraform.io/modules/terraform-aws-modules/cloudfront/aws/latest
module "cloudfront_grafana_takehiro1111_com" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "3.4.1"

  # aws_cloudfront_origin_access_control
  create_origin_access_control = false

  # aws_cloudfront_distribution
  create_distribution = true
  aliases             = [module.value.grafana_takehiro1111_com]
  comment             = module.value.grafana_takehiro1111_com
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  # web_acl_id =  WAF作成時にコメントイン予定

  logging_config = {
    bucket          = data.terraform_remote_state.development_storage.outputs.s3_bucket_domain_name_cdn_access_log
    prefix          = replace(module.value.grafana_takehiro1111_com, ".", "-")
    include_cookies = false
  }

  // ALB
  origin = {
    origin_alb = {
      domain_name = module.alb_wildcard_takehiro1111_com.dns_name
      origin_id   = module.alb_wildcard_takehiro1111_com.dns_name

      custom_origin_config = {
        http_port                = 80
        https_port               = 443
        origin_protocol_policy   = "https-only"
        origin_ssl_protocols     = ["TLSv1.2"]
        origin_keepalive_timeout = 5
        origin_read_timeout      = 20
      }
    }
  }

  default_cache_behavior = {
    target_origin_id       = module.alb_wildcard_takehiro1111_com.dns_name
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "PUT", "POST", "OPTIONS", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    use_forwarded_values   = false

    cache_policy_id            = data.aws_cloudfront_cache_policy.managed_caching_disabled.id
    origin_request_policy_id   = data.aws_cloudfront_origin_request_policy.managed_allviewer.id
    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.security_headers.id
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
    Name = module.value.grafana_takehiro1111_com
  }
}

/* 
 * locust.takehiro1111.com
 */
# ref: https://registry.terraform.io/modules/terraform-aws-modules/cloudfront/aws/latest
module "cloudfront_locust_takehiro1111_com" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "3.4.1"

  # aws_cloudfront_origin_access_control
  create_origin_access_control = false

  # aws_cloudfront_distribution
  create_distribution = true
  aliases             = [module.value.locust_takehiro1111_com]
  comment             = module.value.locust_takehiro1111_com
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  # web_acl_id =  WAF作成時にコメントイン予定

  logging_config = {
    bucket          = data.terraform_remote_state.development_storage.outputs.s3_bucket_domain_name_cdn_access_log
    prefix          = replace(module.value.locust_takehiro1111_com, ".", "-")
    include_cookies = false
  }

  // ALB
  origin = {
    origin_alb = {
      domain_name = module.alb_wildcard_takehiro1111_com.dns_name
      origin_id   = module.alb_wildcard_takehiro1111_com.dns_name

      custom_origin_config = {
        http_port                = 80
        https_port               = 443
        origin_protocol_policy   = "https-only"
        origin_ssl_protocols     = ["TLSv1.2"]
        origin_keepalive_timeout = 5
        origin_read_timeout      = 20
      }
    }
  }

  default_cache_behavior = {
    target_origin_id       = module.alb_wildcard_takehiro1111_com.dns_name
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "PUT", "POST", "OPTIONS", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    use_forwarded_values   = false

    cache_policy_id            = data.aws_cloudfront_cache_policy.managed_caching_disabled.id
    origin_request_policy_id   = data.aws_cloudfront_origin_request_policy.managed_allviewer.id
    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.security_headers.id
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
    Name = module.value.locust_takehiro1111_com
  }
}



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
