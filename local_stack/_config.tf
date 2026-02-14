terraform {
  required_version = "1.14.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.32.1"
    }
  }

  backend "local" {
    path = "test/local-stack"
  }

  # backend "s3" {
  #   bucket                      = "my-first-bucket"
  #   key                         = "test/terraform.tfstate"
  #   region                      = "ap-northeast-1"
  #   skip_credentials_validation = true
  #   skip_requesting_account_id  = true
  #   force_path_style            = true
  #   endpoint                    = "http://localhost:4566"
  # }
}

provider "aws" {
  region     = "ap-northeast-1"
  access_key = "test"
  secret_key = "test"

  endpoints {
    s3             = "http://localhost:4566"
    ec2            = "http://localhost:4566"
    dynamodb       = "http://localhost:4566"
    cloudformation = "http://localhost:4566"
    cloudwatch     = "http://localhost:4566"
    iam            = "http://localhost:4566"
    lambda         = "http://localhost:4566"
    rds            = "http://localhost:4566"
    route53        = "http://localhost:4566"
    sns            = "http://localhost:4566"
    sqs            = "http://localhost:4566"
    ssm            = "http://localhost:4566"
    sts            = "http://localhost:4566"
  }

  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true

  default_tags {
    tags = {
      Env           = "production"
      Configuration = "terraform"
    }
  }
}



