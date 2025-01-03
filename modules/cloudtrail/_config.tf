terraform {
  required_version = ">=1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.76.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
}
