##########################################################################
# Terraform Block
##########################################################################
terraform {
  required_version = "1.14.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.100.0"
    }
  }

  backend "s3" {
    bucket = "terraform-state-122627526840-dst"
    key    = "comp/stg/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

##########################################################################
# Provider Block
##########################################################################
provider "aws" {
  region = "ap-northeast-1"

  default_tags {
    tags = {
      repository = local.repository
      directory  = local.directory
      env        = local.env
    }
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
}

##########################################################################
# Module Block
##########################################################################
module "value" {
  source = "../../modules/variable"
}

##########################################################################
# Data Block
##########################################################################
data "aws_caller_identity" "self" {}
