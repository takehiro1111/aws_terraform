# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
    terraform {
      required_version = "1.9.8"
      required_providers {
        aws = {
          version = "5.74.0"
        }
        random = {
          source  = "hashicorp/random"
          version = "3.6.3"
        }
        http = {
          source  = "hashicorp/http"
          version = "3.4.5"
        }
        awscc = {
          source  = "hashicorp/awscc"
          version = "1.19.0"
        }
      }
    }

    provider "aws" {
      profile = "development_administrator"
      region  = "ap-northeast-1"

      default_tags {
        tags = {
          repository = "aws_terraform"
          directory  = "development/security"
          service    = "security"
        }
      }
    }

    provider "aws" {
      alias  = "us-east-1"
      region = "us-east-1"
      profile = "development_administrator"
    }

    provider "awscc" {
      alias  = "us-east-1"
      region = "us-east-1"
      profile = "development_administrator"
    }