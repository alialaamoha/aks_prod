terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    tls = { 
      source = "hashicorp/tls"

  }
  local = {
    source = "hashicorp/local"
  }
  azuread = {
    source ="hashicorp/azuread"
  }
  }
  
}