#####################################################
# Route53
#####################################################
/* 
 * takehiro1111.com
 */
module "route53_zones" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "4.1.0"

  create = true
  zones = {
    takehiro1111_com = {
      force_destroy = true
      domain_name   = module.value.takehiro1111_com
    }
  }
}

module "route53_records_takehiro1111_com" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "4.1.0"

  create    = true
  zone_id   = module.route53_zones.route53_zone_zone_id.takehiro1111_com
  zone_name = module.route53_zones.route53_zone_name.takehiro1111_com

  records = [
    {
      name    = trimprefix(module.route53_zones.route53_zone_name.takehiro1111_com, module.value.takehiro1111_com)
      type    = "NS"
      ttl     = 300
      records = module.route53_zones.route53_zone_name_servers.takehiro1111_com
    },
    {
      name = trimprefix(module.route53_zones.route53_zone_name.takehiro1111_com, module.value.takehiro1111_com)
      type = "SOA"
      ttl  = 300
      records = [
        "${module.route53_zones.primary_name_server.takehiro1111_com} awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400"
      ]
    },
    {
      name = trimsuffix(module.value.cdn_takehiro1111_com, ".${module.value.takehiro1111_com}")
      type = "A"
      alias = {
        name                   = module.cdn_takehiro1111_com.cloudfront_distribution_domain_name
        zone_id                = module.cdn_takehiro1111_com.cloudfront_distribution_hosted_zone_id
        evaluate_target_health = false
      }
    }
  ]
}

#####################################################
# ACM
#####################################################
## us-east-1
module "acm_takehiro1111_com_us_east_1" {
  source  = "terraform-aws-modules/acm/aws"
  version = "5.1.1"

  # aws_acm_certificate
  create_certificate        = true
  domain_name               = module.value.wildcard_takehiro1111_com
  subject_alternative_names = [module.value.takehiro1111_com]
  validation_method         = "DNS"

  # aws_route53_record
  create_route53_records = true
  zone_id                = module.route53_zones.route53_zone_zone_id.takehiro1111_com

  # aws_acm_certificate_validation
  wait_for_validation = true

  providers = {
    aws = aws.us-east-1
  }
}

## ap-northeast-1
module "acm_takehiro1111_com_ap_northeast_1" {
  source  = "terraform-aws-modules/acm/aws"
  version = "5.1.1"

  # aws_acm_certificate
  create_certificate        = true
  domain_name               = module.value.wildcard_takehiro1111_com
  subject_alternative_names = [module.value.takehiro1111_com]
  validation_method         = "DNS"

  # aws_route53_record
  create_route53_records = true
  zone_id                = module.route53_zones.route53_zone_zone_id.takehiro1111_com

  # aws_acm_certificate_validation
  wait_for_validation = false
}

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

module "cdn_takehiro1111_com" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "3.4.1"

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
  comment             = "common"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  # web_acl_id =  WAF作成時にコメントイン予定

  logging_config = {
    bucket          = aws_s3_bucket.cdn_log.bucket_domain_name
    prefix          = local.logging_config_prefix
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
        origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
        origin_keepalive_timeout = 5
        origin_read_timeout      = 20
      }
    },

    origin_s3 = {
      domain_name           = aws_s3_bucket.static.bucket_regional_domain_name
      origin_id             = aws_s3_bucket.static.bucket_regional_domain_name
      origin_access_control = module.cdn_takehiro1111_com.cloudfront_origin_access_controls.oac_takehiro1111_com.name

      origin_shield = {
        enabled              = true
        origin_shield_region = data.aws_region.default.name
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

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
  }

  ordered_cache_behavior = [
    {
      target_origin_id       = aws_s3_bucket.static.bucket_regional_domain_name
      path_pattern           = "/static/*"
      allowed_methods        = ["GET", "HEAD"]
      cached_methods         = ["GET", "HEAD"]
      compress               = false
      viewer_protocol_policy = "redirect-to-https"
      use_forwarded_values   = false
      cache_policy_id        = data.aws_cloudfront_cache_policy.managed_caching_optimized.id
    }
  ]

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

#####################################################
# ALB
#####################################################
module "alb_wildcard_takehiro1111_com" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.11.1"

  # aws_lb
  create                     = true
  name                       = local.servicename
  load_balancer_type         = "application"
  internal                   = false
  enable_deletion_protection = false

  vpc_id  = module.vpc_common.vpc_id
  subnets = module.vpc_common.public_subnets

  create_security_group = false
  security_groups = [
    aws_security_group.alb_stg.id,
    aws_security_group.alb_9000.id,
  ]

  access_logs = {
    enabled = true
    bucket  = module.s3_alb_accesslog.s3_bucket_id
    prefix  = local.servicename
  }

  # aws_lb_listener
  ## aws_alb_listener_rule
  listeners = {
    https_443 = {
      port            = 443
      protocol        = "HTTPS"
      ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
      certificate_arn = module.acm_takehiro1111_com_ap_northeast_1.acm_certificate_arn
      fixed_response = {
        content_type = "text/html"
        message_body = "Fixed response "
        status_code  = "503"
      }

      rules = {
        web = {
          priority = 2
          conditions = [
            {
              host_header = {
                values = [module.value.cdn_takehiro1111_com]
              }
            },
            {
              path_pattern = {
                values = ["*"]
              }
            }
          ]
          actions = [
            {
              type             = "forward"
              target_group_arn = module.alb_wildcard_takehiro1111_com.target_groups.web.arn
            }
          ]
        }
      }
    }
  }

  # aws_lb_target_group
  target_groups = {
    web = {
      name                 = "${local.servicename}-web"
      port                 = 80
      protocol             = "HTTP"
      deregistration_delay = "60"
      proxy_protocol_v2    = false
      vpc_id               = module.vpc_common.vpc_id
      target_type          = "ip"
      create_attachment    = false

      health_check = {
        healthy_threshold   = 5
        interval            = 60
        matcher             = "200"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 30
        unhealthy_threshold = 2
      }
    }
  }
}
