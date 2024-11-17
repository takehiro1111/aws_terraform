provider "aws" {
  region  = "ap-northeast-1"

  default_tags {
    tags = {
      repository = "aws_terraform"
      directory  = "development/management"
      service    = "management"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
}
