output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "vnet_id" {
  value = module.vnet.vnet_id
}

output "vm_private_ssh_key" {
  value     = tls_private_key.ssh.private_key_pem
  sensitive = true
}

output "storage_account_name" {
  value = azurerm_storage_account.this.name
}
