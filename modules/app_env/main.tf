locals {
  # Common prefix ensuring standard naming convention across the environment
  prefix = "opella-${var.environment}-${var.location}"
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${local.prefix}"
  location = var.location
  tags     = var.tags
}

module "vnet" {
  source = "../vnet" # Reuse the VNET module

  vnet_name           = "vnet-${local.prefix}"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  address_space       = var.vnet_address_space

  subnets = {
    "sn-compute" = {
      address_prefixes = [cidrsubnet(var.vnet_address_space[0], 8, 1)]
    }
  }
  tags = var.tags
}

# Storage Account
resource "random_id" "storage" {
  byte_length = 4
}

resource "azurerm_storage_account" "this" {
  # Name must be globally unique, hence random_id
  name                     = "st${replace(local.prefix, "-", "")}${random_id.storage.hex}"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = var.environment == "prod" ? "GRS" : "LRS" # Example of dynamic setup
  tags                     = var.tags
}

# Network Interface for VM
resource "azurerm_network_interface" "this" {
  name                = "nic-vm-${local.prefix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.vnet.subnet_ids["sn-compute"]
    private_ip_address_allocation = "Dynamic"
  }
  tags = var.tags
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Virtual Machine (Linux)
resource "azurerm_linux_virtual_machine" "this" {
  name                = "vm-${local.prefix}"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  size                = "Standard_B1s" # Free tier eligible
  admin_username      = var.vm_admin_username
  network_interface_ids = [
    azurerm_network_interface.this.id,
  ]
  tags = var.tags

  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = tls_private_key.ssh.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                        = "kv-${var.environment}-${random_id.storage.hex}"
  location                    = var.location
  resource_group_name         = azurerm_resource_group.this.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
  tags                        = var.tags

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Set", "Get", "Delete", "Purge", "Recover", "List"
    ]
  }
}

resource "azurerm_key_vault_secret" "ssh_private_key" {
  name         = "vm-ssh-private-key"
  value        = tls_private_key.ssh.private_key_pem
  key_vault_id = azurerm_key_vault.this.id
}
