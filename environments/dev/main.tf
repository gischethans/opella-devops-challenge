terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-opella-tfstate"
    storage_account_name = "stopellatfstate0941"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
}

module "app_env" {
  source = "../../modules/app_env"

  environment        = "dev"
  vnet_address_space = ["10.0.0.0/16"]

  tags = {
    Environment = "dev"
    Project     = "Opella"
    ManagedBy   = "Terraform"
  }
}

output "key_vault_name" {
  value = module.app_env.key_vault_name
}

output "storage_account_name" {
  value = module.app_env.storage_account_name
}
