#####################################################
# Terraform Block
#####################################################
terraform {
  required_version = "1.9.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.72.1"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-421643133281"
    key            = "lambda/state_lambda"
    region         = "ap-northeast-1"
    acl            = "private"
    encrypt        = true
    dynamodb_table = "tfstate-locks"
  }
}

#####################################################
# Provider Block
#####################################################
provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      Name        = local.servicename
      environment = local.env
      repository  = local.repository
      directory   = local.directory
    }
  }
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

provider "aws" {
  alias  = "eu-central-1"
  region = "eu-central-1"

  default_tags {
    tags = {
      Name       = "hashicorp"
      repository = "hcl"
    }
  }
}

#####################################################
# PMOdule Block
#####################################################
module "value" {
  source = "../modules/variable"
}

#####################################################
# Data Block
#####################################################
data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "default" {
  name = "ap-northeast-1"
}

data "terraform_remote_state" "common" {
  backend = "s3"
  config = {
    bucket         = "terraform-state-421643133281"
    key            = "common/state_common"
    region         = "ap-northeast-1"
  }
}
