terraform {
  required_version = ">= 1.3.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.34.0"
    }
    volterra = {
      source  = "volterraedge/volterra"
      version = "0.11.16"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}
}

provider "volterra" {
  # Configuration options
}