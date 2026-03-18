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
    key                  = "prod.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
}

module "app_env" {
  source = "../../modules/app_env"

  environment        = "prod"
  vnet_address_space = ["10.1.0.0/16"]

  tags = {
    Environment = "prod"
    Project     = "Opella"
    ManagedBy   = "Terraform"
  }
}

output "vm_private_ssh_key" {
  value     = module.app_env.vm_private_ssh_key
  sensitive = true
}

output "storage_account_name" {
  value = module.app_env.storage_account_name
}
