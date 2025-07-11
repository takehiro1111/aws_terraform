############################################################
# VPC
############################################################
output "vpc_ips" {
  value = {
    development = "10.0.1.0/24"
    stats_stg   = "192.168.0.0/24"
    comp_stg    = "172.168.1.0/24"
  }
}

############################################################
# Subnet
############################################################
output "subnet_ips_development" {
  value = {
    a_public  = "10.0.1.0/26"
    c_public  = "10.0.1.64/26"
    a_private = "10.0.1.128/26"
    c_private = "10.0.1.192/26"
  }
}

output "subnet_ips_stats_stg" {
  value = {
    a_public  = "192.168.0.0/27"
    c_public  = "192.168.0.32/27"
    a_private = "192.168.0.96/27"
    c_private = "192.168.0.128/27"
  }
}

output "subnet_ips_comp_stg" {
  value = {
    a_public  = "172.168.1.0/27"
    c_public  = "172.168.1.32/27"
    a_private = "172.168.1.96/27"
    c_private = "172.168.1.128/27"
  }
}

############################################################
# Security Group
############################################################
output "full_open_ip" {
  value = "0.0.0.0/0"
}
