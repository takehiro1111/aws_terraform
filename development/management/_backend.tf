# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
terraform {
  backend "s3" {
    bucket = "tfstate-650251692423"
    key    = "development/management/tfstate"
    region = "ap-northeast-1"
  }
}
