# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
provider "aws" {
  profile = "development_administrator"
  region  = "ap-northeast-1"

  default_tags {
    tags = {
      repository = "aws_terraform"
      directory  = "development/storage"
      service    = "storage"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
}
