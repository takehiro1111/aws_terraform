remote_state {
  backend = "s3"

  config = {
    bucket = "tfstate-650251692423"
    key    = "development/${path_relative_to_include()}.tfstate"
    region = "ap-northeast-1"
    profile = "development_administrator"
  }

  generate = {
    path      = "_backend.tf"
    if_exists = "overwrite"
  }
}

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
      }
    }

    provider "aws" {
      profile = "development_administrator"
      region  = "ap-northeast-1"

      default_tags {
        tags = {
          repository = "aws_terraform"
          directory  = "development_servvices/${path_relative_to_include()}"
          service    = "${path_relative_to_include()}"
        }
      }
    }
  EOF
}
