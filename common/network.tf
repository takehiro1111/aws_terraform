#=========================================
# VPC
#=========================================
resource "aws_vpc" "hashicorp" {
  cidr_block           = module.value.vpc_ip.hcl
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    "Name" = "hcl"
  }
}

# VPCフローログ ----------------------------
# resource "aws_flow_log" "cloudwatch_logs" {
#   iam_role_arn         = aws_iam_role.flow_log.arn
#   log_destination_type = "cloud-watch-logs"
#   log_destination      = aws_cloudwatch_log_group.flow_log.arn
#   traffic_type         = "ACCEPT"
#   vpc_id               = aws_vpc.hashicorp.id

#   tags = {
#     Name = "cloudwatch-logs"
#   }
# }

#::memo::
# フローログを直接S3に流す場合は、IAMロールのアタッチは不要。
# resource "aws_flow_log" "flow_log_s3" {
#   log_destination_type = "s3"
#   log_destination      = aws_s3_bucket.flow_log.arn
#   traffic_type         = "ACCEPT"
#   log_format = "$${account-id} $${region} $${interface-id} $${srcaddr} $${dstaddr} $${pkt-srcaddr} $${pkt-dstaddr} $${protocol} $${action} $${log-status}" 
#   vpc_id                   = aws_vpc.hashicorp.id
#   max_aggregation_interval = 60

#   tags = {
#     Name = "s3"
#   }
# }

#=========================================
# Gateway
#=========================================
resource "aws_internet_gateway" "hashicorp" {
  vpc_id = aws_vpc.hashicorp.id
  tags = {
    "Name" = "hashicorp-igw"
  }
}

# resource "aws_nat_gateway" "hashicorp" {
#   allocation_id = aws_eip.nat.id
#   subnet_id     = aws_subnet.public_a.id

#   tags = {
#     "Name" = "hashicorp-nat"
#   }
# }

#=========================================
# EIP
#=========================================
# resource "aws_eip" "nat" {
#   tags = {
#     Name = "nat"
#   }
# }

// Prometheusサーバ用
resource "aws_eip" "public_instance" {
  domain = "vpc"

  depends_on = [
    aws_internet_gateway.hashicorp
  ]

  tags = {
    Name = "prometheus-server"
  }
}

resource "aws_eip_association" "public_instance" {
  instance_id   = module.prometheus_server.instance_id
  allocation_id = aws_eip.public_instance.id
}

// Prometheusサーバの監視対象であるNodeExporter用
resource "aws_eip" "node_exporter" {
  domain = "vpc"

  depends_on = [
    aws_internet_gateway.hashicorp
  ]

  tags = {
    Name = "node-exporter"
  }
}

resource "aws_eip_association" "node_exporter" {
  instance_id   = module.node_exporter.instance_id
  allocation_id = aws_eip.node_exporter.id
}

#=========================================
# Subnet
#=========================================
#Public-----------------------------------
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.hashicorp.id
  cidr_block              = module.value.hashicorp_subnet_ip.a_public
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false

  tags = {
    "Name" = "public-sn-1"
  }
}

resource "aws_subnet" "public_c" {
  vpc_id                  = aws_vpc.hashicorp.id
  cidr_block              = module.value.hashicorp_subnet_ip.c_public
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = false

  tags = {
    "Name" = "public-sn-2"
  }
}

resource "aws_subnet" "public_d" {
  vpc_id                  = aws_vpc.hashicorp.id
  cidr_block              = module.value.hashicorp_subnet_ip.d_public
  availability_zone       = "ap-northeast-1d"
  map_public_ip_on_launch = false

  tags = {
    "Name" = "public-sn-3"
  }
}

#Private-----------------------------------
resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.hashicorp.id
  cidr_block              = module.value.hashicorp_subnet_ip.a_private
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false

  tags = {
    "Name" = "private-a"
  }
}

resource "aws_subnet" "private_c" {
  vpc_id                  = aws_vpc.hashicorp.id
  cidr_block              = module.value.hashicorp_subnet_ip.c_private
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = false

  tags = {
    "Name" = "private-c"
  }
}

resource "aws_subnet" "private_d" {
  vpc_id                  = aws_vpc.hashicorp.id
  cidr_block              = module.value.hashicorp_subnet_ip.d_private
  availability_zone       = "ap-northeast-1d"
  map_public_ip_on_launch = false

  tags = {
    "Name" = "private-d"
  }
}

# resource "aws_subnet" "private_d" {
#   vpc_id                  = aws_vpc.hashicorp.id
#   cidr_block              = module.value.hashicorp_subnet_ip.d_private
#   availability_zone       = "ap-northeast-1d"
#   map_public_ip_on_launch = false

#   tags = {
#     "Name" = "private-d"
#   }
# }

#=========================================
# RouteTable
#=========================================
#Public-----------------------------------
resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.hashicorp.id

  route {
    cidr_block = module.value.full_open_ip
    gateway_id = aws_internet_gateway.hashicorp.id
  }

  tags = {
    "Name" = "public-rtb"
  }

  depends_on = [aws_vpc.hashicorp]
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rtb.id
}

resource "aws_route_table_association" "public_c" {
  subnet_id      = aws_subnet.public_c.id
  route_table_id = aws_route_table.public_rtb.id
}

resource "aws_route_table_association" "public_d" {
  subnet_id      = aws_subnet.public_d.id
  route_table_id = aws_route_table.public_rtb.id
}

#Private-----------------------------------
resource "aws_route_table" "private_rtb" {
  vpc_id = aws_vpc.hashicorp.id

  tags = {
    "Name" = "private-rtb"
  }

  depends_on = [aws_vpc.hashicorp]
}

# resource "aws_route" "private_rtb_nat" {
#   route_table_id         = aws_route_table.private_rtb.id
#   destination_cidr_block = module.value.full_open_ip
#   nat_gateway_id         = aws_nat_gateway.hashicorp.id
# }

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_rtb.id
}

resource "aws_route_table_association" "private_c" {
  subnet_id      = aws_subnet.private_c.id
  route_table_id = aws_route_table.private_rtb.id
}

resource "aws_route_table_association" "private_d" {
  subnet_id      = aws_subnet.private_d.id
  route_table_id = aws_route_table.private_rtb.id
}

#=========================================
# VPC Endpoint
#=========================================
# resource "aws_vpc_endpoint" "s3" {
#   vpc_id            = aws_vpc.hashicorp.id
#   service_name      = "com.amazonaws.ap-northeast-1.s3"
#   vpc_endpoint_type = "Gateway"
#   route_table_ids   = [aws_route_table.private_rtb.id]

#   tags = {
#     "Name" = "${local.env}-s3"
#   }
# }

# resource "aws_vpc_endpoint_route_table_association" "s3" {
#   route_table_id  = aws_route_table.private_rtb.id
#   vpc_endpoint_id = aws_vpc_endpoint.s3.id
# }

# resource "aws_vpc_endpoint" "ecr_dkr" {
#   vpc_id            = aws_vpc.hashicorp.id
#   subnet_ids = [aws_subnet.private_c.id]
#   service_name      = "com.amazonaws.ap-northeast-1.ecr.dkr"
#   vpc_endpoint_type = "Interface"

#   security_group_ids = [
#     aws_security_group.vpce.id,
#   ]

#   private_dns_enabled = true

#   tags = {
#     "Name" = "${local.env}-ecr-dkr"
#   }
# }

# resource "aws_vpc_endpoint" "ecr_api" {
#   vpc_id            = aws_vpc.hashicorp.id
#   subnet_ids = [aws_subnet.private_c.id]
#   service_name      = "com.amazonaws.ap-northeast-1.ecr.api"
#   vpc_endpoint_type = "Interface"

#   security_group_ids = [
#     aws_security_group.vpce.id,
#   ]

#   private_dns_enabled = true

#   tags = {
#     "Name" = "${local.env}-ecr-api"
#   }
# }

# resource "aws_vpc_endpoint" "logs" {
#   vpc_id            = aws_vpc.hashicorp.id
#   subnet_ids = [aws_subnet.private_c.id]
#   service_name      = "com.amazonaws.ap-northeast-1.logs"
#   vpc_endpoint_type = "Interface"

#   security_group_ids = [
#     aws_security_group.vpce.id,
#   ]

#   private_dns_enabled = true

#   tags = {
#     "Name" = "${local.env}-ecr-logs"
#   }
# }

# resource "aws_vpc_endpoint" "to_td_egent" {
#   count = var.activation_vpc_endpoint ? 1 : 0

#   vpc_id            = aws_vpc.hashicorp.id
#   subnet_ids = [
#     aws_subnet.private_a.id,
#     aws_subnet.private_c.id
#   ]
#   service_name      = data.terraform_remote_state.stats_stg.outputs.td_vpc_endpoint_service_service_name
#   vpc_endpoint_type = "Interface"

#   security_group_ids = [
#     module.vpc_endpoint.security_group_id
#   ]

#   private_dns_enabled = true

#   tags = {
#     "Name" = "${local.env}-td-agent"
#   }
# }
