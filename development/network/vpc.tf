#################################################
# Network Resources
#################################################
# ref:https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
module "vpc_common" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.15.0"

  ## tags
  name = format("%s-%s", var.environment, local.repository)

  ### VPC ###
  cidr                                 = module.value.vpc_ip.hcl
  instance_tenancy                     = "default"
  enable_dns_support                   = true
  enable_dns_hostnames                 = true
  enable_network_address_usage_metrics = false

  ### IGW ###
  create_igw = true

  ### NAT GW ###
  enable_nat_gateway     = false // Will be changed to true when using compute resources.
  single_nat_gateway     = true  // To reduce costs, each private subnet points to a single NAT GW.
  one_nat_gateway_per_az = true  // Place NAT GW in a single AZ for cost reasons. Because Accept reduced availability.

  ### Subnet ###
  ## Shared
  azs = [
    module.value.az.ap_northeast_1.a,
    module.value.az.ap_northeast_1.c
  ]

  ## Public
  public_subnets = [
    module.value.subnet_ip_common.a_public,
    module.value.subnet_ip_common.c_public
  ]

  map_public_ip_on_launch                           = false
  public_subnet_private_dns_hostname_type_on_launch = "ip-name"

  ## Private 
  private_subnets = [
    module.value.subnet_ip_common.a_private,
    module.value.subnet_ip_common.c_private
  ]
  private_subnet_private_dns_hostname_type_on_launch = "ip-name"


  ## RouteTable ###
  create_multiple_public_route_tables = false
  ## Public
  // Created automatically when you configure a public subnet.

  ## Private
  // Created when a NAT GW is created.

  manage_default_vpc            = false
  manage_default_security_group = false
  manage_default_network_acl    = false
  manage_default_route_table    = false
}

#####################################################
# VPC Endpoint
#####################################################
# ref: https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest/submodules/vpc-endpoints
module "vpce_common" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "5.15.0"

  vpc_id = module.vpc_common.vpc_id
  endpoints = {
    s3_gateway = {
      create          = false
      service_name    = "com.amazonaws.${data.aws_region.default.name}.s3"
      service_type    = "Gateway"
      route_table_ids = module.vpc_common.private_route_table_ids
      tags            = { Name = "s3-vpce-gateway" }
    }
    ecr_dkr = {
      create             = false
      subnet_ids         = module.vpc_common.private_subnets
      service_name       = "com.amazonaws.${data.aws_region.default.id}.ecr.dkr"
      security_group_ids = [module.vpc_endpoint.security_group_id]
      tags               = { Name = "ecr-docker-vpce-interface" }
    }
    ecr_api = {
      create             = false
      subnet_ids         = module.vpc_common.private_subnets
      service_name       = "com.amazonaws.${data.aws_region.default.id}.ecr.api"
      security_group_ids = [module.vpc_endpoint.security_group_id]
      tags               = { Name = "ecr-api-vpce-interface" }
    }
    logs = {
      create             = false
      subnet_ids         = module.vpc_common.private_subnets
      service_name       = "com.amazonaws.${data.aws_region.default.id}.logs"
      security_group_ids = [module.vpc_endpoint.security_group_id]
      tags               = { Name = "logs-vpce-interface" }
    }
  }
}

#####################################################
# VPC FlowLogs
#####################################################
# # VPCフローログ ----------------------------
# resource "aws_flow_log" "common" {
#   for_each = { for k, v in local.flow_logs : k => v if v.create }

#   iam_role_arn         = aws_iam_role.flow_log.arn
#   log_destination_type = each.value.log_destination_type
#   log_destination      = each.value.log_destination
#   log_format           = each.value.log_format
#   traffic_type         = each.value.traffic_type
#   vpc_id               = module.vpc_common.vpc_id

#   tags = {
#     Name = each.key
#   }

#   depends_on = [aws_vpc.common]
# }

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
