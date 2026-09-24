terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-tfstate-dev"
    storage_account_name = "sttfstate130022"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    use_oidc             = true
  }
}


provider "azurerm" {
  features {}
}
