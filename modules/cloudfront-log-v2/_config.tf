################################################################################
# Terraform
################################################################################
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.5.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = ">=1.29.0"
    }
  }
}
