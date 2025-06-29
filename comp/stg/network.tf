#################################################
# Network Resources
#################################################
# ref:https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
# module "vpc_comp_stg" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "5.21.0"

#   ## tags
#   name = replace(module.value.comp_takehiro1111_com, ".", "-")

#   ### VPC ###
#   cidr                                 = module.value.vpc_ips.comp_stg
#   instance_tenancy                     = "default"
#   enable_dns_support                   = true
#   enable_dns_hostnames                 = true
#   enable_network_address_usage_metrics = false

#   ### IGW ###
#   create_igw = true

#   ### NAT GW ###
#   enable_nat_gateway     = true // Will be changed to true when using compute resources.
#   single_nat_gateway     = true // To reduce costs, each private subnet points to a single NAT GW.
#   one_nat_gateway_per_az = true // Place NAT GW in a single AZ for cost reasons. Because Accept reduced availability.

#   ### Subnet ###
#   ## Shared
#   azs = [
#     module.value.az.ap_northeast_1.a,
#     module.value.az.ap_northeast_1.c
#   ]

#   ## Public
#   public_subnets = [
#     module.value.subnet_ips_comp_stg.a_public,
#     module.value.subnet_ips_comp_stg.c_public
#   ]

#   map_public_ip_on_launch                           = false
#   public_subnet_private_dns_hostname_type_on_launch = "ip-name"

#   ## Private 
#   private_subnets = [
#     module.value.subnet_ips_comp_stg.a_private,
#     module.value.subnet_ips_comp_stg.c_private
#   ]
#   private_subnet_private_dns_hostname_type_on_launch = "ip-name"


#   ## RouteTable ###
#   create_multiple_public_route_tables = false
#   ## Public
#   // Created automatically when you configure a public subnet.

#   ## Private
#   // Created when a NAT GW is created.

#   manage_default_vpc            = false
#   manage_default_security_group = false
#   manage_default_network_acl    = false
#   manage_default_route_table    = false
# }
