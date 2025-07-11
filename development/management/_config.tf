##########################################################################
# Terraform Block
##########################################################################
terraform {
  required_version = "1.12.2"
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
      version = "1.49.0"
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

# data "aws_region" "default" {
#   name = "ap-northeast-1"
# }

##########################################################################
# Rmote State Data Block
##########################################################################
# data "terraform_remote_state" "development_storage" {
#   backend = "s3"

#   config = {
#     bucket = "tfstate-650251692423"
#     key    = "development/storage/tfstate"
#     region = "ap-northeast-1"
#   }
# }

data "terraform_remote_state" "development_security" {
  backend = "s3"

  config = {
    bucket = "tfstate-650251692423"
    key    = "development/security/tfstate"
    region = "ap-northeast-1"
  }
}

data "terraform_remote_state" "development_compute" {
  backend = "s3"

  config = {
    bucket = "tfstate-650251692423"
    key    = "development/compute/tfstate"
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

data "terraform_remote_state" "master_account_management" {
  backend = "s3"
  config = {
    bucket = "tfstate-685339645368"
    key    = "account_management/tfstate"
    region = "ap-northeast-1"
  }
}

