# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
provider "aws" {
  region = "ap-northeast-1"

  default_tags {
    tags = {
      repository = "aws_terraform"
      directory  = "development/."
      service    = "."
    }
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
}
