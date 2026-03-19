output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "vnet_id" {
  value = module.vnet.vnet_id
}

output "key_vault_name" {
  value = azurerm_key_vault.this.name
}

output "storage_account_name" {
  value = azurerm_storage_account.this.name
}
