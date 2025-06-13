terraform {
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
