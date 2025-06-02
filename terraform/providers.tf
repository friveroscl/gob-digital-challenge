terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "gob-digital-terraform-state"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
  }
}


provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Environment = "test"
      Owner       = "friveros"
      Managed-by  = "Terraform"
    }
  }
}
