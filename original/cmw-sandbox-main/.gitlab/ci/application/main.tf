terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.48.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }
  backend "http" {
  }
  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Name        = var.app_name
    }
  }
}

provider "aws" {
  alias  = "global"
  region = "us-east-1"
}
