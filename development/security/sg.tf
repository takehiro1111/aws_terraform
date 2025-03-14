/* 
 * VPC Origin
 */
module "sg_vpc_origin" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  use_name_prefix = false
  name            = "CloudFront-VPCOrigins-Service-SG"
  description     = "CloudFront configured SecurityGroup"
  vpc_id          = data.terraform_remote_state.development_network.outputs.vpc_id_development
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    Name                       = "sg-vpc-origin"
    "aws.cloudfront.vpcorigin" = "enabled"
  }
}

# ALB--------------------------------------
resource "aws_security_group" "alb_stg" {
  name        = "alb-stg"
  description = "Allow inbound alb"
  vpc_id      = data.terraform_remote_state.development_network.outputs.vpc_id_development

  tags = {
    "Name" = "alb-stg"
  }
}

// VPCオリジンの運用に変更したため削除。(2024/12/24)
# resource "aws_vpc_security_group_ingress_rule" "alb_stg_443" {
#   security_group_id = aws_security_group.alb_stg.id
#   description       = "Allow inbound rule for https"
#   from_port         = 443
#   to_port           = 443
#   ip_protocol       = "tcp"
#   prefix_list_id    = data.aws_ec2_managed_prefix_list.cdn.id

#   tags = {
#     Name = "alb-stg-443"
#   }
# }

resource "aws_vpc_security_group_ingress_rule" "alb_vpc_origin" {
  security_group_id            = aws_security_group.alb_stg.id
  description                  = "Allow inbound rule for https"
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  referenced_security_group_id = "sg-0f5f3aeba40341fbb"

  tags = {
    Name = "sg-vpc-origin"
  }
}

resource "aws_vpc_security_group_egress_rule" "alb_stg_eggress" {
  security_group_id = aws_security_group.alb_stg.id
  description       = "Allow outbound rule for all"
  ip_protocol       = "all"
  cidr_ipv4         = module.value.full_open_ip

  tags = {
    Name = "alb-stg-egress"
  }
}

resource "aws_security_group" "alb_9000" {
  name        = "alb-9000"
  description = "Allow inbound alb"
  vpc_id      = data.terraform_remote_state.development_network.outputs.vpc_id_development

  tags = {
    "Name" = "alb-9000"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_stg_9000_cdn" {
  security_group_id = aws_security_group.alb_9000.id
  description       = "Allow developers for blue-green deployments"
  from_port         = 9000
  to_port           = 9000
  ip_protocol       = "tcp"
  prefix_list_id    = data.aws_ec2_managed_prefix_list.cdn.id

  tags = {
    Name = "alb-stg-9000-cdn"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_stg_9000_myip" {
  security_group_id = aws_security_group.alb_9000.id
  description       = "Allow developers for blue-green deployments"
  from_port         = 9000
  to_port           = 9000
  ip_protocol       = "tcp"
  cidr_ipv4         = data.terraform_remote_state.development_management.outputs.ssm_parameter_store_my_ip

  tags = {
    Name = "alb-stg-9000-my-ip"
  }
}

resource "aws_vpc_security_group_egress_rule" "alb_9000_eggress" {
  security_group_id = aws_security_group.alb_9000.id
  description       = "Allow outbound rule for all"
  ip_protocol       = "all"
  cidr_ipv4         = module.value.full_open_ip

  tags = {
    Name = "alb-9000-egress"
  }
}

# ECS & EC2 ------------------------------------
resource "aws_security_group" "ecs_stg" {
  name        = "ecs-stg"
  description = "Allow inbound alb"
  vpc_id      = data.terraform_remote_state.development_network.outputs.vpc_id_development

  tags = {
    "Name" = "ecs-stg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ecs_stg_for_alb" {
  security_group_id            = aws_security_group.ecs_stg.id
  description                  = "Allow inbound rule alb"
  from_port                    = 0
  to_port                      = 65535
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.alb_stg.id

  tags = {
    "Name" = "ecs-stg-for-alb"
  }
}

resource "aws_vpc_security_group_ingress_rule" "between_ecs" {
  security_group_id            = aws_security_group.ecs_stg.id
  description                  = "Allow inbound rule ecs"
  from_port                    = 0
  to_port                      = 65535
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.ecs_stg.id

  tags = {
    "Name" = "ecs-stg-between-ecs"
  }
}

resource "aws_vpc_security_group_egress_rule" "ecs_stg_egress" {
  security_group_id = aws_security_group.ecs_stg.id
  description       = "Allow outbound rule for all"
  ip_protocol       = "all"
  cidr_ipv4         = module.value.full_open_ip

  tags = {
    Name = "ecs-stg-egress"
  }
}

#MySQL ------------------------------------- 
module "sg_mysql" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  // SG本体
  name        = "aurora-mysql"
  description = "SecurityGroup for Aurora MySQL"
  vpc_id      = data.terraform_remote_state.development_network.outputs.vpc_id_development
  // ルール
  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "MySQL access from VPC"
      cidr_blocks = join(",", [
        module.value.subnet_ips_development.a_private,
        module.value.subnet_ips_development.c_private,
      ])
    }
  ]
  ingress_with_source_security_group_id = [
    {
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      description              = "MySQL Inbound from Source SG"
      source_security_group_id = aws_security_group.ecs_stg.id
    }
  ]
  ingress_with_prefix_list_ids = [
    {
      from_port               = 443
      to_port                 = 443
      protocol                = "tcp"
      description             = "Allow Inbound From CloludFront"
      ingress_prefix_list_ids = data.aws_ec2_managed_prefix_list.cdn.id
    }
  ]

  egress_rules = ["all-all"]
}

resource "aws_vpc_security_group_ingress_rule" "mysql_stg_cdn" {
  security_group_id = module.sg_mysql.security_group_id
  description       = "Allow inbound rule for https"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  prefix_list_id    = data.aws_ec2_managed_prefix_list.cdn.id

  tags = {
    Name = "mysql-stg-cdn"
  }
}


module "vpc_endpoint" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"


  name        = "stats-fluentd"
  description = "SG for log routing"
  vpc_id      = data.terraform_remote_state.development_network.outputs.vpc_id_development

  ingress_with_source_security_group_id = [
    {
      from_port                = 24224
      to_port                  = 24224
      protocol                 = "tcp"
      description              = "Log Routing"
      source_security_group_id = aws_security_group.ecs_stg.id
    }
  ]

  egress_rules = ["all-all"]
}

module "vpce_ssm" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"


  name        = "vpce-ssm"
  description = "SG for log routing"
  vpc_id      = data.terraform_remote_state.development_network.outputs.vpc_id_development

  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = module.value.vpc_ips.development
    }
  ]

  egress_rules = ["all-all"]

  tags = {
    Name = "sg-vpce-ssm"
  }
}

module "sg_ec2_ssm" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "5.3.0"
  name        = "vpce-ssm"
  description = "SG for log routing"
  vpc_id      = data.terraform_remote_state.development_network.outputs.vpc_id_development

  ingress_with_source_security_group_id = [
    {
      from_port                = 0
      to_port                  = 0
      protocol                 = "all"
      source_security_group_id = module.sg_ec2_ssm.security_group_id
    },
    {
      from_port                = 0
      to_port                  = 0
      protocol                 = "all"
      source_security_group_id = aws_security_group.alb_stg.id
    }
  ]

  ingress_with_cidr_blocks = [
    // For Grafana Server
    {
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      cidr_blocks = module.value.full_open_ip
    },
    // For Prometheus Server
    {
      from_port   = 9090
      to_port     = 9090
      protocol    = "tcp"
      cidr_blocks = module.value.full_open_ip
    },
    // For Node Exporter
    {
      from_port   = 9100
      to_port     = 9100
      protocol    = "tcp"
      cidr_blocks = module.value.full_open_ip
    },
    // For Blackbox Exporter
    {
      from_port   = 9115
      to_port     = 9115
      protocol    = "tcp"
      cidr_blocks = module.value.full_open_ip
    }
  ]

  egress_rules = ["all-all"]

  tags = {
    Name = "sg-ec2-ssm"
  }
}

