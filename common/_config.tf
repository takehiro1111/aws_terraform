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
      version = "1.17.0"
    }
  }

  backend "s3" {
    bucket  = "terraform-state-421643133281"
    key     = "common/state_common"
    region  = "ap-northeast-1"
    acl     = "private"
    encrypt = true
    # dynamodb_table = "tfstate-locks"
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
  alias  = "ap-southeast-1"
  region = "ap-southeast-1"
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

provider "awscc" {
  region = "us-east-1"
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

  owners = [local.aws_owner] # Amazonの所有者ID
}

data "aws_ec2_managed_prefix_list" "cdn" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

data "aws_ec2_managed_prefix_list" "s3" {
  name = "com.amazonaws.ap-northeast-1.s3"
}

# data "terraform_remote_state" "stats_stg" {
#   backend = "s3"
#   config = {
#     bucket         = "terraform-state-hashicorp"
#     key            = "stats"
#     region         = "ap-northeast-1"
#     acl            = "private"
#     encrypt        = true
#     dynamodb_table = "tfstate-locks"
#   }
# }
