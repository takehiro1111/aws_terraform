##########################################################################
# Terraform Block
##########################################################################
terraform {
  required_version = "1.12.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.98.0"
    }
  }

  backend "local" {
    path = "state/terraform.tfstate"
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
