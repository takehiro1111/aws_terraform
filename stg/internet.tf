#===================================
# Route53
#===================================
/* 
 * tanaka-test.education.nextbeat.dev
 */
# resource "aws_route53_zone" "sekigaku" {
#   name = module.value.sekigaku
# }

# resource "aws_route53_record" "sekigaku_default_ns" {
#   allow_overwrite = true
#   name            = module.value.sekigaku
#   type            = "NS"
#   zone_id         = aws_route53_zone.sekigaku.id
#   ttl             = 172800

#   records = aws_route53_zone.sekigaku.name_servers
# }

# resource "aws_route53_record" "sekigaku_default_soa" {
#   name    = module.value.sekigaku
#   type    = "SOA"
#   zone_id = aws_route53_zone.sekigaku.id
#   ttl     = 900

#   records = [
#     "${aws_route53_zone.sekigaku.primary_name_server}. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400"

#   ]
# }

// CloudFrontへのエイリアスレコード
# resource "aws_route53_record" "cloudfront_alias" {
#   zone_id = aws_route53_zone.sekigaku.zone_id
#   name    = module.value.cloudfront_domain
#   type    = "A"

#   alias {
#     name                   = aws_cloudfront_distribution.stg.domain_name
#     zone_id                = aws_cloudfront_distribution.stg.hosted_zone_id
#     evaluate_target_health = false
#   }
# }

# resource "aws_route53_record" "cdn_function" {
#   zone_id = aws_route53_zone.sekigaku.zone_id
#   name    = module.value.cdn_function
#   type    = "A"

#   alias {
#     name                   = aws_cloudfront_distribution.stg.domain_name
#     zone_id                = aws_cloudfront_distribution.stg.hosted_zone_id
#     evaluate_target_health = false
#   }
# }

//ACMのドメイン検証用
# resource "aws_route53_record" "hashicorp_ap_northeast_1" {
#   for_each = {
#     for dvo in aws_acm_certificate.hashicorp.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }

#   allow_overwrite = true // 既存のレコードがある場合は上書きする
#   name            = each.value.name
#   records         = [each.value.record]
#   type            = each.value.type
#   ttl             = 60
#   zone_id         = aws_route53_zone.sekigaku.zone_id
# }

# resource "aws_route53_record" "hashicorp_us_east_1" {
#   for_each = {
#     for dvo in aws_acm_certificate.hashicorp_us_east_1.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }

#   allow_overwrite = true
#   name            = each.value.name
#   records         = [each.value.record]
#   ttl             = 60
#   type            = each.value.type
#   zone_id         = aws_route53_zone.sekigaku.zone_id
# }

/* 
 * stg-tanaka.education.nextbeat.dev
 */
# resource "aws_route53_zone" "stg" {
#   name = module.value.stg_tanaka_education_nextbeat_dev
# }

# resource "aws_route53_record" "stg_default_ns" {
#   allow_overwrite = true
#   name            = module.value.stg_tanaka_education_nextbeat_dev
#   type            = "NS"
#   zone_id         = aws_route53_zone.stg.id
#   ttl             = 172800

#   records = aws_route53_zone.stg.name_servers
# }

# resource "aws_route53_record" "stg_default_soa" {
#   name    =  module.value.stg_tanaka_education_nextbeat_dev
#   type    = "SOA"
#   zone_id = aws_route53_zone.stg.id
#   ttl     = 900

#   records = [
#     "${aws_route53_zone.stg.primary_name_server}. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400"

#   ]
# }

//ACMのドメイン検証用
# resource "aws_route53_record" "stg_ap_northeast_1" {
#   for_each = {
#     for dvo in aws_acm_certificate.stg.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }

#   allow_overwrite = true // 既存のレコードがある場合は上書きする
#   name            = each.value.name
#   records         = [each.value.record]
#   type            = each.value.type
#   ttl             = 60
#   zone_id         = aws_route53_zone.stg.zone_id
# }

# resource "aws_route53_record" "stg_us_east_1" {
#   for_each = {
#     for dvo in aws_acm_certificate.stg_us_east_1.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }

#   allow_overwrite = true
#   name            = each.value.name
#   records         = [each.value.record]
#   ttl             = 60
#   type            = each.value.type
#   zone_id         = aws_route53_zone.stg.zone_id
# }


/* 
 * tanaka-cloud.net
 */
resource "aws_route53_zone" "tanaka_cloud_net" {
  name = module.value.tanaka_cloud_net
}

resource "aws_route53_record" "tanaka_cloud_net_default_ns" {
  allow_overwrite = true
  name            = module.value.tanaka_cloud_net
  type            = "NS"
  zone_id         = aws_route53_zone.tanaka_cloud_net.id
  ttl             = 172800

  records = aws_route53_zone.tanaka_cloud_net.name_servers
}

resource "aws_route53_record" "tanaka_cloud_net_default_soa" {
  name    = module.value.tanaka_cloud_net
  type    = "SOA"
  zone_id = aws_route53_zone.tanaka_cloud_net.id
  ttl     = 900

  records = [
    "${aws_route53_zone.tanaka_cloud_net.primary_name_server}. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400"

  ]
}

# ACM DNS Validation(ap-northeast-1)
resource "aws_route53_record" "tanaka_cloud_net_ap_northeast_1" {
  for_each = {
    for dvo in aws_acm_certificate.tanaka_cloud_net.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true // 既存のレコードがある場合は上書きする
  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type
  ttl             = 60
  zone_id         = aws_route53_zone.tanaka_cloud_net.zone_id
}

# ACM DNS Validation(us-east-1)
resource "aws_route53_record" "tanaka_cloud_net_us_east_1" {
  for_each = {
    for dvo in aws_acm_certificate.tanaka_cloud_net_us_east_1.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.tanaka_cloud_net.zone_id
}

// CloudFrontへのエイリアスレコード
resource "aws_route53_record" "cdn_tanaka_cloud_net" {
  zone_id = aws_route53_zone.tanaka_cloud_net.zone_id
  name    = module.value.cdn_tanaka_cloud_net
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.stg.domain_name
    zone_id                = aws_cloudfront_distribution.stg.hosted_zone_id
    evaluate_target_health = false
  }
}

// ALBへのエイリアスレコード
resource "aws_route53_record" "lb_tanaka_cloud_net" {
  zone_id = aws_route53_zone.tanaka_cloud_net.zone_id
  name    = module.value.lb_tanaka_cloud_net
  type    = "A"

  alias {
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
    evaluate_target_health = false
  }
}

#===================================
#ACM
#===================================
#ALB用
#ap-northeast-1
# resource "aws_acm_certificate" "hashicorp" {
#   domain_name               = module.value.wildcard_sekigaku
#   validation_method         = "DNS"
#   subject_alternative_names = [module.value.sekigaku]

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_acm_certificate_validation" "hashicorp" {
#   certificate_arn         = aws_acm_certificate.hashicorp.arn
#   validation_record_fqdns = [for record in aws_route53_record.hashicorp_ap_northeast_1 : record.fqdn]
# }

#us-east-1
# resource "aws_acm_certificate" "hashicorp_us_east_1" {
#   domain_name               = module.value.wildcard_sekigaku
#   validation_method         = "DNS"
#   subject_alternative_names = [module.value.sekigaku]
#   provider                  = aws.us-east-1

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_acm_certificate_validation" "hashicorp_us_east_1" {
#   certificate_arn         = aws_acm_certificate.hashicorp_us_east_1.arn
#   validation_record_fqdns = [for record in aws_route53_record.hashicorp_us_east_1 : record.fqdn]
#   provider                = aws.us-east-1
# }

# resource "aws_acm_certificate" "stg" {
#   domain_name               = module.value.wildcard_stg_tanaka_education_nextbeat_dev
#   validation_method         = "DNS"
#   subject_alternative_names = [module.value.stg_tanaka_education_nextbeat_dev]

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_acm_certificate_validation" "stg" {
#   certificate_arn         = aws_acm_certificate.stg.arn
#   validation_record_fqdns = [for record in aws_route53_record.stg_ap_northeast_1 : record.fqdn]
# }

# resource "aws_acm_certificate" "stg_us_east_1" {
#   domain_name               = module.value.wildcard_stg_tanaka_education_nextbeat_dev
#   validation_method         = "DNS"
#   subject_alternative_names = [module.value.stg_tanaka_education_nextbeat_dev]
#   provider                  = aws.us-east-1

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_acm_certificate_validation" "stg_us_east_1" {
#   certificate_arn         = aws_acm_certificate.stg_us_east_1.arn
#   validation_record_fqdns = [for record in aws_route53_record.stg_us_east_1 : record.fqdn]
#   provider                = aws.us-east-1
# }

resource "aws_acm_certificate" "tanaka_cloud_net" {
  domain_name               = module.value.wildcard_tanaka_cloud_net
  validation_method         = "DNS"
  subject_alternative_names = [module.value.tanaka_cloud_net]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate" "tanaka_cloud_net_us_east_1" {
  domain_name               = module.value.wildcard_tanaka_cloud_net
  validation_method         = "DNS"
  subject_alternative_names = [module.value.tanaka_cloud_net]
  provider                  = aws.us-east-1

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "tanaka_cloud_net_us_east_1" {
  certificate_arn         = aws_acm_certificate.tanaka_cloud_net_us_east_1.arn
  validation_record_fqdns = [for record in aws_route53_record.tanaka_cloud_net_us_east_1 : record.fqdn]
  provider                  = aws.us-east-1
}

#===================================
#CloudFront
#===================================
data "aws_cloudfront_cache_policy" "managed_caching_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_cache_policy" "managed_caching_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "managed_allviewer" {
  name = "Managed-AllViewer"
}

resource "aws_cloudfront_function" "test" {
  name    = "test-sg"
  runtime = "cloudfront-js-2.0"
  comment = "my function"
  publish = true
  code    = file("../function/function.js")
}

resource "aws_cloudfront_origin_access_control" "oac_stg" {
  description                       = "${aws_s3_bucket.test.id}-oac"
  name                              = "${aws_s3_bucket.test.id}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "stg" {
  aliases = [
    module.value.cdn_tanaka_cloud_net
  ]

  enabled         = true
  is_ipv6_enabled = true
  price_class     = "PriceClass_All"
  #web_acl_id      = aws_wafv2_web_acl.region_count.arn

  // ALB
  origin {
    domain_name = aws_lb.this.dns_name
    origin_id   = local.ecs_origin_id

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      origin_keepalive_timeout = "5"
      origin_read_timeout      = "30"
    }
  }

  // S3
  origin {
    domain_name              = aws_s3_bucket.test.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.test.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac_stg.id
  }

  ordered_cache_behavior {
    path_pattern           = "/maintenance/*"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.test.bucket_regional_domain_name
    compress               = false
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = data.aws_cloudfront_cache_policy.managed_caching_optimized.id
  }

  ordered_cache_behavior {
    path_pattern             = "/index.php"
    allowed_methods          = ["GET", "HEAD"]
    cached_methods           = ["GET", "HEAD"]
    target_origin_id         = local.ecs_origin_id
    compress                 = false
    viewer_protocol_policy   = "redirect-to-https"
    cache_policy_id          = data.aws_cloudfront_cache_policy.managed_caching_disabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.managed_allviewer.id
  }

  default_cache_behavior {
    allowed_methods          = ["GET", "HEAD", "DELETE", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods           = ["GET", "HEAD"]
    target_origin_id         = local.ecs_origin_id
    compress                 = true
    viewer_protocol_policy   = "redirect-to-https"
    cache_policy_id          = data.aws_cloudfront_cache_policy.managed_caching_disabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.managed_allviewer.id

    # function_association {
    #   event_type   = "viewer-request"
    #   function_arn = aws_cloudfront_function.test.arn
    # }
  }

  //S3bucket作成してからコメントイン予定
  /*  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.cdn_log.bucket
    prefix          = "cloudfront"
  } */

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate.tanaka_cloud_net_us_east_1.arn
    cloudfront_default_certificate = "false"
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }

  dynamic "custom_error_response" {
    for_each = var.full_maintenance || var.half_maintenance ? [1] : [0]

    content {
      error_caching_min_ttl = 10
      error_code            = 503
      response_code         = 503
      response_page_path    = "/maintenance/maintenance.html"
    }
  }

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

  tags = {
    "Name" : "hashicorp"
  }
}

#===================================
#ALB
#===================================
resource "aws_lb" "this" {
  name               = "ecs"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [
    aws_security_group.alb_stg.id, 
    aws_security_group.alb_9000.id, 
    aws_vpc.hashicorp.default_security_group_id
  ]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_c.id]

  enable_deletion_protection = false
  drop_invalid_header_fields = true
  depends_on                 = [aws_vpc.hashicorp]

  /*  access_logs {
    bucket  = aws_s3_bucket.logging-sekigaku-20231120.bucket
    enabled = true
  } */
}

#Listener------------------------------------
resource "aws_lb_listener" "alb_443" {
  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.tanaka_cloud_net.arn
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Fixed response "
      status_code  = "503"
    }
  }
}

resource "aws_lb_listener" "alb_9000" {
  load_balancer_arn = aws_lb.this.arn
  port              = "9000"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.tanaka_cloud_net.arn
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Fixed response "
      status_code  = "503"
    }
  }
}

#ListenerRule--------------------------------
resource "aws_lb_listener_rule" "redirect" {
  listener_arn = aws_lb_listener.alb_443.arn
  priority     = 1

  action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
      host        = module.value.cloudfront_domain
      path        = "/input.html"
    }
  }

  condition {
    host_header {
      values = [module.value.cdn_function]
    }
  }
}

resource "aws_alb_listener_rule" "nginx" {
  listener_arn = aws_lb_listener.alb_443.arn
  priority     = 2

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx.arn
  }

  condition {
    host_header {
      values = [module.value.cdn_tanaka_cloud_net]
    }
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
}

resource "aws_lb_listener_rule" "alb_443_rule" {
  listener_arn = aws_lb_listener.alb_443.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ec2.arn
  }

  condition {
    host_header {
      values = [module.value.cloudfront_domain]
    }
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
}

#TargetGroup---------------------------------
resource "aws_lb_target_group" "web" {
  name                 = "web"
  port                 = 80
  protocol             = "HTTP"
  deregistration_delay = "60"
  proxy_protocol_v2    = false
  vpc_id               = aws_vpc.hashicorp.id
  target_type          = "ip"

  health_check {
    healthy_threshold   = 5
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "api" {
  name                 = "api"
  port                 = 80
  protocol             = "HTTP"
  deregistration_delay = "60"
  proxy_protocol_v2    = false
  vpc_id               = aws_vpc.hashicorp.id
  target_type          = "ip"

  health_check {
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

resource "aws_lb_target_group" "nginx" {
  name                 = "nginx"
  port                 = 80
  protocol             = "HTTP"
  deregistration_delay = "60"
  proxy_protocol_v2    = false
  vpc_id               = aws_vpc.hashicorp.id
  target_type          = "ip"

  health_check {
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

resource "aws_lb_target_group" "ec2" {
  name                 = "ec2"
  port                 = 80
  protocol             = "HTTP"
  deregistration_delay = "60"
  proxy_protocol_v2    = false
  vpc_id               = aws_vpc.hashicorp.id
  target_type          = "instance"

  health_check {
    healthy_threshold   = 5
    interval            = 60
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 30
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group_attachment" "ec2" {
  target_group_arn = aws_lb_target_group.ec2.arn
  target_id        = module.prometheus_server.instance_id
  port             = 80
}
