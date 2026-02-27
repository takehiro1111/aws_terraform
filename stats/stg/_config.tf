#=============================================
#Terraform Block
#=============================================
terraform {
  required_version = "1.14.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.34.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-421643133281"
    key            = "stats"
    region         = "ap-northeast-1"
    acl            = "private"
    encrypt        = true
    dynamodb_table = "tfstate-locks"
  }
}

#=============================================
#Provider Block
#=============================================
provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      Name       = local.service
      env        = local.env
      repository = local.repo
      directory  = local.dir
    }
  }
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

#=============================================
#Module Block
#=============================================
module "value" {
  source = "../../modules/variable"
}

#=============================================
#Data Block
#=============================================
data "aws_caller_identity" "self" {}

data "aws_partition" "self" {}

data "aws_region" "self" {
  name = "ap-northeast-1"
}


