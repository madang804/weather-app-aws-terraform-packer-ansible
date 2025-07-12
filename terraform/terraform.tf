terraform {
  cloud {
    organization = "Madan0804-Org"
    workspaces {
      name = "weather-app-aws-terraform-packer-ansible"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>6.2.0"
    }
  }
}
