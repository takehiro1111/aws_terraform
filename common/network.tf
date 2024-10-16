#####################################################
# VPC
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

#####################################################
# VPC Endpoint
#####################################################
// S3だけではなく、他のDynamoDBも想定した書き方にする。
# resource "aws_vpc_endpoint" "s3_gateway" {
#   count = var.s3_gateway ? 1 : 0

#   vpc_id            = module.vpc_common.vpc_id
#   service_name      = "com.amazonaws.${data.aws_region.default.name}.s3"
#   route_table_ids   = [aws_route_table.common["private"].id]
#   vpc_endpoint_type = "Gateway"

#   tags = {
#     "Name" = "s3-common"
#   }
# }

# resource "aws_vpc_endpoint_route_table_association" "s3_gateway" {
#   count = var.s3_gateway ? 1 : 0

#   route_table_id  = aws_route_table.common["private"].id
#   vpc_endpoint_id = aws_vpc_endpoint.s3_gateway[0].id
# }

# resource "aws_vpc_endpoint" "interface" {
#   for_each           = { for k, v in local.vpce_interface : k => v if v.create }
#   vpc_id             = module.vpc_common.vpc_id
#   subnet_ids         = each.value.subnet_ids
#   service_name       = each.value.service_name
#   vpc_endpoint_type  = "Interface"
#   security_group_ids = each.value.security_group_ids

#   private_dns_enabled = true

#   tags = {
#     "Name" = each.key
#   }
# }


#################################################
# Network Resources
#################################################
# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
module "vpc_common" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  ## tags
  name = format("%s-%s",local.servicename,local.repository)

  ### VPC ###
  cidr = module.value.vpc_ip.hcl
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  enable_network_address_usage_metrics = false

  ### IGW ###
  create_igw = true

  ### NAT GW ###
  enable_nat_gateway = false // Will be changed to true when using compute resources.
  single_nat_gateway = true // To reduce costs, each private subnet points to a single NAT GW.
  one_nat_gateway_per_az = true // Place NAT GW in a single AZ for cost reasons. Because Accept reduced availability.

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

  map_public_ip_on_launch  = false
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

  manage_default_vpc = false
  manage_default_security_group = false
  manage_default_network_acl = false
  manage_default_route_table  = false
}
