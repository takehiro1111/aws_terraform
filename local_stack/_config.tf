terraform {
  required_version = "1.13.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.10.0"
    }
  }

  backend "s3" {
    bucket                      = "my-first-bucket"
    key                         = "test/terraform.tfstate"
    region                      = "ap-northeast-1"
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    force_path_style            = true
    endpoint                    = "http://localhost:4566"
  }
}

provider "aws" {
  region     = "ap-northeast-1"
  access_key = "test"
  secret_key = "test"

  endpoints {
    s3  = "http://localhost:4566"
    ec2 = "http://localhost:4566"
  }

  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}



