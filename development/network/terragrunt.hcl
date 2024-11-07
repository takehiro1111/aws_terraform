include {
  path = find_in_parent_folders()
}


generate "config" {
  path      = "_config.tf"
  if_exists = "overwrite"
  
  contents = <<EOF
module "value" {
  source = "../../modules/variable"
}

data "aws_caller_identity" "self" {}

data "aws_partition" "current" {}

data "aws_region" "default" {
  name = "ap-northeast-1"
}

data "http" "myip" {
  url = "http://ifconfig.me/"
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] # Amazonの所有者ID
}

data "aws_ec2_managed_prefix_list" "cdn" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

data "aws_ec2_managed_prefix_list" "s3" {
  name = "com.amazonaws.ap-northeast-1.s3"
}
  EOF
}
