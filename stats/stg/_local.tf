locals {
  service = "stats"
  env = "stg"
  repo = "aws_terraform"
  dir = "stats/stg"

  category = {
    net = "network"
  }
}

locals {
  sg_object = {
    log_routing = {
      from_port   = 24224
      to_port     = 24224
      protocol    = "tcp"
      description = "Log Routing"
      cidr_blocks = module.value.hashicorp_subnet_ip.a_private
    },
    log_routing_2 = {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Log Routing"
      cidr_blocks = module.value.hashicorp_subnet_ip.a_private
    }
  }
}
