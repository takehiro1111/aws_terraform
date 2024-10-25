#####################################################
# Terraform Block
#####################################################
terraform {
  required_version = "1.9.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.73.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = "1.18.0"
    }
  }

  backend "s3" {
    bucket  = "tfstate-685339645368"
    key     = "prod/state_prod"
    region  = "ap-northeast-1"
    profile = "my_account"
  }
}

#####################################################
# Provider Block
#####################################################
provider "aws" {
  region  = "ap-northeast-1"
  profile = "my_account"

  default_tags {
    tags = {
      Name        = local.name
      Environment = local.env
      Repository  = local.repo
      Directory   = local.dir
    }
  }
}

provider "aws" {
  alias   = "us-east-1"
  region  = "us-east-1"
  profile = "my_account"

  default_tags {
    tags = {
      Name        = local.name
      Environment = local.env
      Repository  = local.repo
      Directory   = local.dir
    }
  }
}

provider "awscc" {
  region  = "us-east-1"
  profile = "my_account"
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
