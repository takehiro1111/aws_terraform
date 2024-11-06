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
          repository = "${local.repository}"
          directory  = "${local.env}/${path_relative_to_include()}"
          service    = "${path_relative_to_include()}"
        }
      }
    }

    provider "aws" {
      alias  = "us-east-1"
      region = "us-east-1"
      profile = "development_administrator"
    }

    provider "awscc" {
      alias  = "us-east-1"
      region = "us-east-1"
      profile = "development_administrator"
    }
  EOF
}

#####################################################
# local
#####################################################
locals {
  environment = "development"
  repository = "aws_terraform"
}

inputs = {
  environment = local.environment
  project     = local.project
}

#####################################################
# Data Block
#####################################################
generate "data_sources" {
  path      = "_data_sources.tf"
  if_exists = "overwrite"
  
  contents = <<EOF
    data "aws_caller_identity" "self" {}

    data "aws_partition" "current" {}

    data "aws_region" "default" {
      name = "ap-northeast-1"
    }

    data "http" "myip" {
      url = "http://ifconfig.me/"
    }

    data "aws_ami" "amazon_linux" {
      most_recent = true

      filter {
        name   = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
      }

      filter {
        name   = "virtualization-type"
        values = ["hvm"]
      }

      owners = ["137112412989"] # Amazonの所有者ID
    }

    data "aws_ec2_managed_prefix_list" "cdn" {
      name = "com.amazonaws.global.cloudfront.origin-facing"
    }

    data "aws_ec2_managed_prefix_list" "s3" {
      name = "com.amazonaws.ap-northeast-1.s3"
    }
  EOF
}
