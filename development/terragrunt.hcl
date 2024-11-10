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
