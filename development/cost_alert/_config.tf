##########################################################################
# Terraform Block
##########################################################################
terraform {
  required_version = "1.16.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.100.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.8.1"
    }
  }
}

##########################################################################
# Basic Data Block
##########################################################################
data "aws_caller_identity" "self" {}

