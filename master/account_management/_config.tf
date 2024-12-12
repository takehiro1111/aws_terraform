#####################################################
# Terraform Block
#####################################################
terraform {
  required_version = "1.10.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.80.0"
    }
  }

  backend "s3" {
    bucket  = "tfstate-685339645368"
    key     = "account_management/tfstate"
    region  = "ap-northeast-1"
    profile = "master_administrator"
  }
}

#####################################################
# Provider Block
#####################################################
provider "aws" {
  region  = "ap-northeast-1"
  profile = "master_administrator"

  default_tags {
    tags = {
      Name       = local.service_name
      repository = local.repo
      directory  = local.dir
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  alias   = "us-east-1"
  profile = "master_administrator"

  default_tags {
    tags = {
      Name       = local.service_name
      repository = local.repo
      directory  = local.dir
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

data "aws_partition" "current" {}

data "aws_region" "default" {
  name = "ap-northeast-1"
}

data "aws_region" "us_east_1" {
  name = "us-east-1"
}

data "terraform_remote_state" "master_state" {
  backend = "s3"
  config = {
    bucket = "tfstate-685339645368"
    key    = "state/state_prod"
    region = "ap-northeast-1"
  }
}

data "terraform_remote_state" "development_state" {
  backend = "s3"
  config = {
    bucket = "tfstate-650251692423"
    key    = "state/development"
    region = "ap-northeast-1"
  }
}

data "terraform_remote_state" "master_storage" {
  backend = "s3"
  config = {
    bucket = "tfstate-685339645368"
    key    = "sam/tfstate"
    region = "ap-northeast-1"
  }
}
