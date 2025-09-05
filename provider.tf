terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "zeynab"

    workspaces {
      name = "Management"
    }
  }
}


provider "aws" {
  region = var.region
}
