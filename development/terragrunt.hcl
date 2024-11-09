#####################################################
# Remote State
#####################################################
remote_state {
  backend = "s3"

  config = {
    bucket = "tfstate-650251692423"
    key    = "development/${path_relative_to_include()}/tfstate"
    region = "ap-northeast-1"
    profile = "development_administrator"
  }

  generate = {
    path      = "_backend.tf"
    if_exists = "overwrite"
  }
}

#####################################################
# Terraform & Provider Block
#####################################################
generate "provider" {
  path      = "_provider.tf"
  if_exists = "overwrite"

  contents = <<EOF
terraform {
  required_version = "1.9.8"
  required_providers {
    aws = {
      version = "5.74.0"
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
      version = "1.19.0"
    }
  }
}

provider "aws" {
  profile = "development_administrator"
  region  = "ap-northeast-1"

  default_tags {
    tags = {
      repository = "${local.repository_yml.repository}"
      directory  = "${local.env_yml.env}/${path_relative_to_include()}"
      service    = "${path_relative_to_include()}"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
}
  EOF
}

#####################################################
# local
#####################################################
locals {
  env_yml = yamldecode(file("locals.yml"))
  repository_yml = yamldecode(file("locals.yml"))
}

# locals {
#   environment = "development"
#   repository = "aws_terraform"
#   env = "dev"
# }

# inputs = {
#   environment = local.environment
# }
