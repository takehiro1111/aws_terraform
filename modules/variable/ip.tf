output "vpc_ip" {
  value = {
    hcl = "10.1.0.0/16",
  }
}

output "hashicorp_subnet_ip" {
  value = {
    a_public  = "10.1.1.0/24"
    c_public  = "10.1.2.0/24"
    d_public  = "10.1.3.0/24"
    a_private = "10.1.4.0/24"
    c_private = "10.1.5.0/24"
    d_private = "10.1.6.0/24"
  }
}

output "full_open_ip" {
  value = "0.0.0.0/0"
}
