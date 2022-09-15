terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.22.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
}
#Authentication methods

#Azure cli
#Managed Service Identity
#Service Principle and a client certificate
#Service Principle and a client Secret
#OpenID Connect

