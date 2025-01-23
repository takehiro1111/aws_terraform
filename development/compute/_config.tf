##########################################################################
# Terraform Block
##########################################################################
terraform {
  required_version = "1.10.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.84.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.5"
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
data "terraform_remote_state" "development_network" {
  backend = "s3"

  config = {
    bucket = "tfstate-650251692423"
    key    = "development/network/tfstate"
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

data "terraform_remote_state" "development_storage" {
  backend = "s3"

  config = {
    bucket = "tfstate-650251692423"
    key    = "development/storage/tfstate"
    region = "ap-northeast-1"
  }
}

data "terraform_remote_state" "development_management" {
  backend = "s3"

  config = {
    bucket = "tfstate-650251692423"
    key    = "development/management/tfstate"
    region = "ap-northeast-1"
  }
}
