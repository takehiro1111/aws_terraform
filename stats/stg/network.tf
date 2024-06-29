#################################################
# Network resources from official modules
#################################################
# module.vpc.aws_default_network_acl.this[0]
# module.vpc.aws_default_route_table.default[0]
# module.vpc.aws_default_security_group.this[0]
# module.vpc.aws_internet_gateway.this[0]
# module.vpc.aws_route.public_internet_gateway[0]
# module.vpc.aws_route_table.private[0]
# module.vpc.aws_route_table.private[1]
# module.vpc.aws_route_table.public[0]
# module.vpc.aws_route_table_association.private[0]
# module.vpc.aws_route_table_association.private[1]
# module.vpc.aws_route_table_association.public[0]
# module.vpc.aws_route_table_association.public[1]
# module.vpc.aws_subnet.private[0]
# module.vpc.aws_subnet.private[1]
# module.vpc.aws_subnet.public[0]
# module.vpc.aws_subnet.public[1]
# module.vpc.aws_vpc.this[0]

# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  ## tags
  name = format("%s-%s-%s",local.service,local.env,local.category.net)

  ### VPC ###
  cidr = module.value.vpc_ip_stg.stats
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  enable_network_address_usage_metrics = false

  ### IGW ###
  create_igw = true

  ### NAT GW ###
  enable_nat_gateway = false // Will be changed to true when using compute resources.
  single_nat_gateway = true // To reduce costs, each private subnet points to a single NAT GW.
  one_nat_gateway_per_az = false // Place NAT GW in a single AZ for cost reasons. Because Accept reduced availability.

  ### Subnet ###
  ## Shared
    azs = [
    module.value.ap_northeast_1.a,
    module.value.ap_northeast_1.c
  ]

  ## Public
  public_subnets = [
    module.value.stats_stg.a_public,
    module.value.stats_stg.c_public
  ]

  map_public_ip_on_launch  = false
  public_subnet_private_dns_hostname_type_on_launch = "ip-name"

  ## Private 
  private_subnets = [
    module.value.stats_stg.a_private,
    module.value.stats_stg.c_private
  ]
  private_subnet_private_dns_hostname_type_on_launch = "ip-name"


  ## RouteTable ###
  ## Public
  // Created automatically when you configure a public subnet.

  ## Private
  // Created when a NAT GW is created.
}

