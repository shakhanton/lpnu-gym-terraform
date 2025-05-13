terraform {
  backend "s3" {
    bucket         = "eu-central-1-terraform-tfstate"
    key            = "gym/dev/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-tfstate-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.97.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "eu-central-1"

}
