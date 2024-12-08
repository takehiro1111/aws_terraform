#####################################################
# ALB
#####################################################

module "alb_wildcard_takehiro1111_com" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.12.0"

  # aws_lb
  create                     = true
  name                       = local.env_yml.env
  load_balancer_type         = "application"
  internal                   = false
  enable_deletion_protection = false

  vpc_id  = module.vpc_development.vpc_id
  subnets = module.vpc_development.public_subnets

  create_security_group = false
  security_groups = [
    data.terraform_remote_state.development_security.outputs.sg_id_alb,
  ]

  access_logs = {
    enabled = true
    bucket  = data.terraform_remote_state.development_storage.outputs.s3_bucket_id_alb_access_log
    prefix  = local.logging_config_prefix
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
              target_group_arn = aws_lb_target_group.web.arn
            }
          ]
        }
        prometheus = {
          priority = 10
          conditions = [
            {
              host_header = {
                values = [module.value.prometheus_takehiro1111_com]
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
              target_group_arn = aws_lb_target_group.prometheus_server.arn
            }
          ]
        }
      }
    }
  }

  # aws_lb_target_group
  # target_groups = {
  #   web = {
  #     name                 = "${local.env_yml.env}-web"
  #     port                 = 80
  #     protocol             = "HTTP"
  #     deregistration_delay = "60"
  #     proxy_protocol_v2    = false
  #     vpc_id               = module.vpc_development.vpc_id
  #     target_type          = "ip"
  #     create_attachment    = true

  #     health_check = {
  #       healthy_threshold   = 5
  #       interval            = 60
  #       matcher             = "200"
  #       path                = "/"
  #       port                = "traffic-port"
  #       protocol            = "HTTP"
  #       timeout             = 30
  #       unhealthy_threshold = 2
  #     }
  #   }
  # }
}

resource "aws_lb_target_group" "web" {
  name                 = "web"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = module.vpc_development.vpc_id
  deregistration_delay = "60"
  proxy_protocol_v2    = false
  target_type          = "ip"
  health_check {
    enabled             = true
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

resource "aws_lb_target_group" "prometheus_server" {
  name                 = "prometheus-server"
  port                 = 9090
  protocol             = "HTTP"
  vpc_id               = module.vpc_development.vpc_id
  deregistration_delay = 300
  proxy_protocol_v2    = false
  target_type          = "instance"
  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = 80
    protocol            = "HTTP"
    timeout             = 10
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group_attachment" "prometheus_server" {
  target_group_arn = aws_lb_target_group.prometheus_server.arn
  target_id        = data.terraform_remote_state.development_compute.outputs.ec2_instance_id_prometheus_server
  port             = 9090 // override用
}
