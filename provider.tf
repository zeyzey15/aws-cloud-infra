terraform {
    cloud {
      organization = "Zeynab"
      
      workspaces {
        name = "Management"
        
      }
    }
  
}


provider "aws" {
    region = "eu-west-1"
  
}