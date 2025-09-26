provider "aws" {
  region = "eu-central-1"
}

terraform {
  required_version = ">= 0.12"
  backend "s3" {
    bucket  = "fab-terraform-state"
    key     = "alpinehuts/terraform.tfstate"
    region  = "eu-central-1"
    encrypt = true
  }
}

data "aws_caller_identity" "current" {}

locals {
  account_id       = data.aws_caller_identity.current.account_id
  region           = "eu-central-1"
}
