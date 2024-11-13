##########################################################################
# Terraform Block
##########################################################################
terraform {
  required_version = "1.9.8"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.75.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.5"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = "1.20.0"
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

##########################################################################
# Rmote State Data Block
##########################################################################
data "terraform_remote_state" "development_storage" {
  backend = "s3"

  config = {
    bucket  = "tfstate-650251692423"
    key     = "development/storage/tfstate"
    region  = "ap-northeast-1"
  }
}
