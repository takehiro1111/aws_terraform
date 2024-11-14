##############################################
# NLB
##############################################
resource "aws_lb" "td" {
  name               = "td-agent"
  internal           = true
  load_balancer_type = "network"
  // 後から設定予定
  # security_groups = [
  #   module.nlb.security_group_id
  # ]
  subnets = [
    element(module.vpc.private_subnets, 0),
    element(module.vpc.private_subnets, 1)
  ]

  enable_deletion_protection = false
  drop_invalid_header_fields = false

  /*  access_logs {
    bucket  = aws_s3_bucket.logging.bucket
    enabled = true
  } */
}

resource "aws_lb_listener" "td" {
  load_balancer_arn = aws_lb.td.arn
  port              = "24224"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.td.arn
  }
}

resource "aws_lb_target_group" "td" {
  connection_termination = false
  deregistration_delay   = "60"
  name                   = "ecs-td-agent"
  port                   = 80
  preserve_client_ip     = "false"
  protocol               = "TCP"
  proxy_protocol_v2      = false
  tags                   = {}
  tags_all               = {}
  target_type            = "ip"
  vpc_id                 = module.vpc.vpc_id
}
