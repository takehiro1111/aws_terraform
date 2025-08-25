##########################################################################
# Terraform Block
##########################################################################
terraform {
  required_version = "1.13.0"

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
      version = "1.53.0"
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

# data "aws_partition" "current" {}

data "aws_region" "default" {
  name = "ap-northeast-1"
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
