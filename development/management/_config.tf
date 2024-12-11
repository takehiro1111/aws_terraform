##########################################################################
# Terraform Block
##########################################################################
terraform {
  required_version = "1.10.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.80.0"
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
      version = "1.23.0"
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

