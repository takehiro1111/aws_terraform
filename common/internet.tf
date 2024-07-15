#####################################################
# Route53
#####################################################
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
    name                   = module.main_stg.cloudfront_distribution_domain_name
    zone_id                = module.main_stg.cloudfront_distribution_hosted_zone_id
    evaluate_target_health = false
  }
}

#####################################################
# ACM
#####################################################
#for ALB
resource "aws_acm_certificate" "tanaka_cloud_net" {
  domain_name               = module.value.wildcard_tanaka_cloud_net
  validation_method         = "DNS"
  subject_alternative_names = [module.value.tanaka_cloud_net]

  lifecycle {
    create_before_destroy = true
  }
}

# for CloudFront
resource "aws_acm_certificate" "tanaka_cloud_net_us_east_1" {
  domain_name               = module.value.wildcard_tanaka_cloud_net
  validation_method         = "DNS"
  subject_alternative_names = [module.value.tanaka_cloud_net]
  provider                  = aws.us-east-1

  lifecycle {
    create_before_destroy = true
  }
}

# Common Use
resource "aws_acm_certificate_validation" "tanaka_cloud_net_us_east_1" {
  certificate_arn         = aws_acm_certificate.tanaka_cloud_net_us_east_1.arn
  validation_record_fqdns = [for record in aws_route53_record.tanaka_cloud_net_us_east_1 : record.fqdn]
  provider                = aws.us-east-1
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

resource "aws_cloudfront_function" "stg" {
  count = var.cdn_stg ? 1 : 0

  name    = "test-sg"
  runtime = "cloudfront-js-2.0"
  comment = "my function"
  publish = true
  code    = file("../function/function.js")
}

resource "aws_cloudfront_origin_access_control" "stg" {
  count = var.cdn_stg ? 1 : 0

  description                       = "${aws_s3_bucket.static.id}-oac"
  name                              = "${aws_s3_bucket.static.id}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "stg" {
  count = var.cdn_stg ? 1 : 0

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
    domain_name              = aws_s3_bucket.static.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.static.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.stg[0].id
  }

  ordered_cache_behavior {
    path_pattern           = "/maintenance/*"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.static.bucket_regional_domain_name
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

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.stg[0].arn
    }
  }

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.cdn_log.bucket_domain_name
    prefix          = "stg"
  }

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
    "Name" : "common"
  }
}

# reference: https://registry.terraform.io/modules/terraform-aws-modules/cloudfront/aws/latest
module "main_stg" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "3.4.0"

  create_origin_access_control = true
  origin_access_control = {
    main-stg-oac = {
      description      = "Official Module Used CDN",
      origin_type      = "s3",
      signing_behavior = "always",
      signing_protocol = "sigv4"
    }
  }

  aliases          = [module.value.cdn_tanaka_cloud_net]
  comment          = "Official Module Used for Test"
  enabled          = true
  is_ipv6_enabled  = true
  price_class      = "PriceClass_All"
  retain_on_delete = false
  # web_acl_id =  WAF作成時にコメントイン予定

  //S3bucket作成してからコメントイン予定
  logging_config = {
    bucket          = aws_s3_bucket.cdn_log.bucket_domain_name
    prefix          = local.logging_config_prefix
    include_cookies = false
  }

  // ALB
  origin = {
    origin-alb = {
      domain_name = aws_lb.this.dns_name
      origin_id   = aws_lb.this.dns_name

      custom_origin_config = {
        http_port                = 80
        https_port               = 443
        origin_protocol_policy   = "https-only"
        origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
        origin_keepalive_timeout = 5
        origin_read_timeout      = 20
      }
    }

    origin-s3 = {
      domain_name           = aws_s3_bucket.static.bucket_regional_domain_name
      origin_id             = aws_s3_bucket.static.bucket_regional_domain_name
      origin_access_control = "main-stg-oac"


      origin_shield = {
        enabled              = true
        origin_shield_region = data.aws_region.default.name
      }
    }
  }

  default_cache_behavior = {
    target_origin_id       = aws_lb.this.dns_name
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
    acm_certificate_arn            = aws_acm_certificate.tanaka_cloud_net_us_east_1.arn
    cloudfront_default_certificate = "false"
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }

  custom_error_response = concat(local.custom_error_responses, local.conditional_custom_error_responses)

  geo_restriction = {
    restriction_type = "none"
  }

  tags = {
    Name = "${local.servicename}-${local.env}"
  }
}

#####################################################
# ALB
#####################################################
resource "aws_lb" "this" {
  name               = "common"
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.alb_stg.id,
    aws_security_group.alb_9000.id,
    aws_vpc.common.default_security_group_id
  ]
  subnets = [aws_subnet.common["public_a"].id, aws_subnet.common["public_c"].id]

  enable_deletion_protection = false
  drop_invalid_header_fields = true
  depends_on                 = [aws_vpc.common]

  access_logs {
    bucket  = module.s3_alb_accesslog.s3_bucket_id
    prefix  = "common"
    enabled = true
  }
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

// Prometheusの学習用
# resource "aws_lb_listener" "alb_9000" {
#   load_balancer_arn = aws_lb.this.arn
#   port              = "9000"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
#   certificate_arn   = aws_acm_certificate.tanaka_cloud_net.arn
#   default_action {
#     type = "fixed-response"

#     fixed_response {
#       content_type = "text/plain"
#       message_body = "Fixed response "
#       status_code  = "503"
#     }
#   }
# }

resource "aws_alb_listener_rule" "nginx" {
  listener_arn = aws_lb_listener.alb_443.arn
  priority     = 2

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_nginx.arn
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

resource "aws_lb_target_group" "ecs_nginx" {
  name                 = "nginx"
  port                 = 80
  protocol             = "HTTP"
  deregistration_delay = "60"
  proxy_protocol_v2    = false
  vpc_id               = aws_vpc.common.id
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

# resource "aws_lb_target_group" "ec2" {
#   name                 = "ec2"
#   port                 = 80
#   protocol             = "HTTP"
#   deregistration_delay = "60"
#   proxy_protocol_v2    = false
#   vpc_id               = aws_vpc.common.id
#   target_type          = "instance"

#   health_check {
#     healthy_threshold   = 5
#     interval            = 60
#     matcher             = "200"
#     path                = "/"
#     port                = "traffic-port"
#     protocol            = "HTTP"
#     timeout             = 30
#     unhealthy_threshold = 3
#   }
# }

# resource "aws_lb_target_group_attachment" "ec2" {
#   target_group_arn = aws_lb_target_group.ec2.arn
#   target_id        = module.prometheus_server.instance_id
#   port             = 80
# }