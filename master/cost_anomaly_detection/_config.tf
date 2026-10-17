#####################################################
# Terraform Block
#####################################################
terraform {
  required_version = "1.16.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.57.1"
    }
  }

  backend "s3" {
    bucket = "tfstate-685339645368"
    key    = "cost_anomaly_detection/tfstate"
    region = "ap-northeast-1"
  }
}

#####################################################
# Provider Block
#####################################################
provider "aws" {
  region = "ap-northeast-1"

  default_tags {
    tags = {
      Name       = local.service_name
      repository = local.repo
      directory  = local.dir
    }
  }
}

#####################################################
# Data Block
#####################################################
data "aws_caller_identity" "self" {}

data "terraform_remote_state" "master_account_management" {
  backend = "s3"
  config = {
    bucket = "tfstate-685339645368"
    key    = "account_management/tfstate"
    region = "ap-northeast-1"
  }
}
