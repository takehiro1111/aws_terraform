#####################################################
# VPC
#####################################################
resource "aws_vpc" "common" {
  cidr_block           = module.value.vpc_ip.hcl
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    "Name" = "common"
  }
}

# VPCフローログ ----------------------------
resource "aws_flow_log" "common" {
  for_each = { for k, v in local.flow_logs : k => v if v.create }

  iam_role_arn         = aws_iam_role.flow_log.arn
  log_destination_type = each.value.log_destination_type
  log_destination      = each.value.log_destination
  log_format           = each.value.log_format
  traffic_type         = each.value.traffic_type
  vpc_id               = aws_vpc.common.id

  tags = {
    Name = each.key
  }

  depends_on = [aws_vpc.common]
}

#####################################################
# IGW
#####################################################
resource "aws_internet_gateway" "common" {
  vpc_id = aws_vpc.common.id
  tags = {
    "Name" = "common-igw"
  }
}

#####################################################
# NAT GW
#####################################################
resource "aws_nat_gateway" "common" {
  count = var.create_nat_gw ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.common["public_a"].id

  tags = {
    "Name" = "common-nat"
  }
}

#####################################################
# EIP
#####################################################
resource "aws_eip" "nat" {
  count = var.create_nat_gw ? 1 : 0

  tags = {
    Name = "nat"
  }
}

# resource "aws_eip" "common" {
#   for_each = { for k, v in local.eip : k => v if v.create }
#   domain   = "vpc"

#   depends_on = [
#     aws_internet_gateway.common
#   ]

#   tags = {
#     Name = each.key
#   }
# }

# resource "aws_eip_association" "common" {
#   for_each = { for k, v in local.eip : k => v if v.create }

#   instance_id   = each.value.instance_id
#   allocation_id = aws_eip.common[each.key].id
# }

#####################################################
# Subnet
#####################################################
resource "aws_subnet" "common" {
  for_each                = { for k, v in local.subnets : k => v }
  vpc_id                  = aws_vpc.common.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = false

  tags = {
    "Name" = each.key
  }
}

#####################################################
# Route Table
#####################################################
#Public-----------------------------------
resource "aws_route_table" "common" {
  for_each = toset(local.rtb)

  vpc_id = aws_vpc.common.id

  tags = {
    "Name" = each.value
  }

  depends_on = [aws_vpc.common]
}

resource "aws_route" "common" {
  for_each = { for k, v in local.route : k => v if v.create }

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
  gateway_id             = each.value.gateway_id
  # nat_gateway_id = each.value.nat_gateway_id
}

resource "aws_route_table_association" "common" {
  for_each       = { for k, v in local.rtb_association : k => v }
  subnet_id      = each.value.subnet_id
  route_table_id = each.value.route_table_id
}

#####################################################
# VPC Endpoint
#####################################################
// S3だけではなく、他のDynamoDBも想定した書き方にする。
resource "aws_vpc_endpoint" "s3_gateway" {
  count = var.s3_gateway ? 1 : 0

  vpc_id            = aws_vpc.common.id
  service_name      = "com.amazonaws.${data.aws_region.default.name}.s3"
  route_table_ids   = [aws_route_table.common["private"].id]
  vpc_endpoint_type = "Gateway"

  tags = {
    "Name" = "s3-common"
  }
}

resource "aws_vpc_endpoint_route_table_association" "s3_gateway" {
  count = var.s3_gateway ? 1 : 0

  route_table_id  = aws_route_table.common["private"].id
  vpc_endpoint_id = aws_vpc_endpoint.s3_gateway[0].id
}

resource "aws_vpc_endpoint" "interface" {
  for_each           = { for k, v in local.vpce_interface : k => v if v.create }
  vpc_id             = aws_vpc.common.id
  subnet_ids         = each.value.subnet_ids
  service_name       = each.value.service_name
  vpc_endpoint_type  = "Interface"
  security_group_ids = each.value.security_group_ids

  private_dns_enabled = true

  tags = {
    "Name" = each.key
  }
}
