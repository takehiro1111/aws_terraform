#####################################################
# ALB
#####################################################
module "alb_wildcard_takehiro1111_com" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.12.0"

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
