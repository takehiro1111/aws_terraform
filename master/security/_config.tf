#####################################################
# Terraform Block
#####################################################
terraform {
  required_version = "1.10.4"

  cloud {
    organization = "takehiro1111"
    hostname     = "app.terraform.io"
    workspaces {
      name = "master_security"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.83.0"
    }
  }

  #   backend "s3" {
  #     # path = "locals/state.tf"
  #     bucket  = "tfstate-685339645368"
  #     key     = "security/tfstate"
  #     region  = "ap-northeast-1"
  #     profile = "master_administrator"
  #   }
}

#####################################################
# Provider Block
#####################################################
provider "aws" {
  region = "ap-northeast-1"
  # profile = "master_administrator"

  default_tags {
    tags = {
      Name       = local.service_name
      repository = local.repo
      directory  = local.dir
    }
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
  // HCP Terraformの場合はローカルの認証ファイルにアクセスできないため、必要ない。
  # profile = "master_administrator"

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
# data "aws_caller_identity" "self" {}

# data "aws_partition" "current" {}

# data "aws_region" "default" {
#   name = "ap-northeast-1"
# }
