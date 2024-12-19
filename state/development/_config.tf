#####################################################
# Terraform Block
#####################################################
terraform {
  required_version = "1.10.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.81.0"
    }
  }

  backend "s3" {
    bucket  = "tfstate-650251692423"
    key     = "state/development"
    region  = "ap-northeast-1"
    profile = "development_administrator"
  }
}

#####################################################
# Provider Block
#####################################################
provider "aws" {
  region  = "ap-northeast-1"
  profile = "development_administrator"

  default_tags {
    tags = {
      Repository = local.repo
      Directory  = local.dir
    }
  }
}

#####################################################
# PMOdule Block
#####################################################
module "value" {
  source = "../../modules/variable"
}

#####################################################
# Data Block
#####################################################
data "aws_caller_identity" "self" {}

data "terraform_remote_state" "master_state" {
  backend = "s3"
  config = {
    bucket = "tfstate-685339645368"
    key    = "state/state_prod"
    region = "ap-northeast-1"
  }
}
