##########################################################################
# Terraform Block
##########################################################################
terraform {
  required_version = "1.14.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.100.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.5.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = "1.64.0"
    }
  }
}

##########################################################################
# Module Block
##########################################################################
module "value" {
  source = "../../modules/variable"
}

##########################################################################
# Basic Data Block
##########################################################################
data "aws_caller_identity" "self" {}

data "aws_partition" "current" {}

data "aws_region" "default" {
  name = "ap-northeast-1"
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

data "http" "myip" {
  url = "http://ifconfig.me/"
}

##########################################################################
# Rmote State Data Block
##########################################################################
data "terraform_remote_state" "development_storage" {
  backend = "s3"

  config = {
    bucket = "tfstate-650251692423"
    key    = "development/storage/tfstate"
    region = "ap-northeast-1"
  }
}

data "terraform_remote_state" "development_security" {
  backend = "s3"

  config = {
    bucket = "tfstate-650251692423"
    key    = "development/security/tfstate"
    region = "ap-northeast-1"
  }
}

data "terraform_remote_state" "development_compute" {
  backend = "s3"

  config = {
    bucket = "tfstate-650251692423"
    key    = "development/compute/tfstate"
    region = "ap-northeast-1"
  }
}
