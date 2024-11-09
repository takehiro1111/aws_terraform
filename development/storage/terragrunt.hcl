include {
  path = find_in_parent_folders()
}

generate "config" {
  path      = "_config.tf"
  if_exists = "overwrite"
  
  contents = <<EOF
module "value" {
  source = "../../modules/variable"
}

data "aws_caller_identity" "self" {}

data "aws_partition" "current" {}

data "aws_region" "default" {
  name = "ap-northeast-1"
}

data "terraform_remote_state" "development_storage" {
  backend = "s3"

  config = {
    bucket  = "tfstate-650251692423"
    key     = "development/storage/tfstate"
    region  = "ap-northeast-1"
  }
}
  EOF
}
