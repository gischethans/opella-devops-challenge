# Azure Free Tier / Restricted Environment Notes

During the implementation of this technical challenge, the provided Azure account encountered common limitations associated with "Free Tier" or strictly-governed DevTest subscriptions. To ensure the Terraform automation functioned natively, the following architecture configurations and manual overrides were applied:

## 1. Unregistered Azure Providers
**Issue**: When attempting to dynamically create the central Remote State Storage Account via our bootstrap Bash script, Azure returned a deceptive `SubscriptionNotFound` API error, despite the subscription clearly existing.
**Cause**: The core `Microsoft.Storage` Resource Provider had never been instantiated/registered in the tenant's background.
**Resolution**: 
Manually triggered the registration of the provider against the subscription using the Azure CLI:
```bash
az provider register -n Microsoft.Storage
```
Once registered, the API correctly permitted the Storage Account (`stopellatfstate`) creation natively.

## 2. Terraform Provider Registration Permissions
**Issue**: When running `terraform plan` to calculate the environment deployments, the pipeline crashed with:
> *Error: Encountered an error whilst ensuring Resource Providers are registered... HTTP response was nil; connection may have been reset.*
**Cause**: By default, Terraform attempts to dynamically register every missing provider API it supports (`Microsoft.Compute`, `Microsoft.Network`, etc.). Free Tier Azure subscriptions typically lack the global directory-level API permissions required to make these sweeping tenant-wide registrations, causing the connection API to forcefully reset the request.
**Resolution**:
We explicitly disabled Terraform's automatic background provider registrations by injecting the `resource_provider_registrations = "none"` property directly into the `azurerm` provider configuration in both the `dev` and `prod` environments:
```hcl
provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
}
```

---

# Final Terraform Plan Outputs

With the above configurations in place, the declarative environments successfully compile against the Azure backend. Here are the verified deployment outputs showing the modular structure in action:

### Development Environment
```text
$ cd environments/dev && terraform plan
Acquiring state lock. This may take a few moments...
module.app_env.data.azurerm_client_config.current: Reading...
module.app_env.data.azurerm_client_config.current: Read complete after 0s [id=Y2xpZW50Q29uZmlncy9jbGllbnRJZD0wNGIwNzc5NS04ZGRiLTQ2MWEtYmJlZS0wMmY5ZTFiZjdiNDY7b2JqZWN0SWQ9YjJlMTkzNDUtOTc4MC00NWM4LWI1MTktYjQ3YTAyMTIwMWQ2O3N1YnNjcmlwdGlvbklkPTg4ODlmMjY2LWM4MDUtNGU2ZS04YTc3LTcyMzUzMTNlMzdmZTt0ZW5hbnRJZD1lOTE4MTA2OS1hMGYxLTQ3ZWMtYWYzOS02ODM2OWVkYjcxM2Q=]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following
symbols:
  + create

Terraform will perform the following actions:

  # module.app_env.azurerm_key_vault.this will be created
  + resource "azurerm_key_vault" "this" {
      + access_policy                 = [
          + {
              + object_id          = "b2e19345-9780-45c8-b519-b47a021201d6"
              + secret_permissions = [
                  + "Set",
                  + "Get",
                  + "Delete",
                  + "Purge",
                  + "Recover",
                  + "List",
                ]
              + tenant_id          = "e9181069-a0f1-47ec-af39-68369edb713d"
            },
        ]
      + enable_rbac_authorization     = (known after apply)
      + enabled_for_disk_encryption   = true
      + id                            = (known after apply)
      + location                      = "eastus"
      + name                          = (known after apply)
      + public_network_access_enabled = true
      + purge_protection_enabled      = false
      + rbac_authorization_enabled    = (known after apply)
      + resource_group_name           = "rg-opella-dev-eastus"
      + sku_name                      = "standard"
      + soft_delete_retention_days    = 7
      + tags                          = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Project"     = "Opella"
        }
      + tenant_id                     = "e9181069-a0f1-47ec-af39-68369edb713d"
      + vault_uri                     = (known after apply)

      + contact (known after apply)

      + network_acls (known after apply)
    }

  # module.app_env.azurerm_key_vault_secret.ssh_private_key will be created
  + resource "azurerm_key_vault_secret" "ssh_private_key" {
      + id                      = (known after apply)
      + key_vault_id            = (known after apply)
      + name                    = "vm-ssh-private-key"
      + resource_id             = (known after apply)
      + resource_versionless_id = (known after apply)
      + value                   = (sensitive value)
      + value_wo                = (write-only attribute)
      + version                 = (known after apply)
      + versionless_id          = (known after apply)
    }

  # module.app_env.azurerm_linux_virtual_machine.this will be created
  + resource "azurerm_linux_virtual_machine" "this" {
      + admin_username                                         = "azureadmin"
      + allow_extension_operations                             = (known after apply)
      + bypass_platform_safety_checks_on_user_schedule_enabled = false
      + computer_name                                          = (known after apply)
      + disable_password_authentication                        = (known after apply)
      + disk_controller_type                                   = (known after apply)
      + extensions_time_budget                                 = "PT1H30M"
      + id                                                     = (known after apply)
      + location                                               = "eastus"
      + max_bid_price                                          = -1
      + name                                                   = "vm-opella-dev-eastus"
      + network_interface_ids                                  = (known after apply)
      + os_managed_disk_id                                     = (known after apply)
      + patch_assessment_mode                                  = (known after apply)
      + patch_mode                                             = (known after apply)
      + platform_fault_domain                                  = -1
      + priority                                               = "Regular"
      + private_ip_address                                     = (known after apply)
      + private_ip_addresses                                   = (known after apply)
      + provision_vm_agent                                     = (known after apply)
      + public_ip_address                                      = (known after apply)
      + public_ip_addresses                                    = (known after apply)
      + resource_group_name                                    = "rg-opella-dev-eastus"
      + size                                                   = "Standard_B1s"
      + tags                                                   = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Project"     = "Opella"
        }
      + virtual_machine_id                                     = (known after apply)
      + vm_agent_platform_updates_enabled                      = (known after apply)

      + admin_ssh_key {
          + public_key = (known after apply)
          + username   = "azureadmin"
        }

      + os_disk {
          + caching                   = "ReadWrite"
          + disk_size_gb              = (known after apply)
          + id                        = (known after apply)
          + name                      = (known after apply)
          + storage_account_type      = "Standard_LRS"
          + write_accelerator_enabled = false
        }

      + source_image_reference {
          + offer     = "0001-com-ubuntu-server-jammy"
          + publisher = "Canonical"
          + sku       = "22_04-lts-gen2"
          + version   = "latest"
        }

      + termination_notification (known after apply)
    }

  # module.app_env.azurerm_network_interface.this will be created
  + resource "azurerm_network_interface" "this" {
      + accelerated_networking_enabled = false
      + applied_dns_servers            = (known after apply)
      + id                             = (known after apply)
      + internal_domain_name_suffix    = (known after apply)
      + ip_forwarding_enabled          = false
      + location                       = "eastus"
      + mac_address                    = (known after apply)
      + name                           = "nic-vm-opella-dev-eastus"
      + private_ip_address             = (known after apply)
      + private_ip_addresses           = (known after apply)
      + resource_group_name            = "rg-opella-dev-eastus"
      + tags                           = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Project"     = "Opella"
        }
      + virtual_machine_id             = (known after apply)

      + ip_configuration {
          + gateway_load_balancer_frontend_ip_configuration_id = (known after apply)
          + name                                               = "internal"
          + primary                                            = (known after apply)
          + private_ip_address                                 = (known after apply)
          + private_ip_address_allocation                      = "Dynamic"
          + private_ip_address_version                         = "IPv4"
          + subnet_id                                          = (known after apply)
        }
    }

  # module.app_env.azurerm_resource_group.this will be created
  + resource "azurerm_resource_group" "this" {
      + id       = (known after apply)
      + location = "eastus"
      + name     = "rg-opella-dev-eastus"
      + tags     = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Project"     = "Opella"
        }
    }

  # module.app_env.azurerm_storage_account.this will be created
  + resource "azurerm_storage_account" "this" {
      + access_tier                        = (known after apply)
      + account_kind                       = "StorageV2"
      + account_replication_type           = "LRS"
      + account_tier                       = "Standard"
      + allow_nested_items_to_be_public    = true
      + cross_tenant_replication_enabled   = false
      + default_to_oauth_authentication    = false
      + dns_endpoint_type                  = "Standard"
      + https_traffic_only_enabled         = true
      + id                                 = (known after apply)
      + infrastructure_encryption_enabled  = false
      + is_hns_enabled                     = false
      + large_file_share_enabled           = (known after apply)
      + local_user_enabled                 = true
      + location                           = "eastus"
      + min_tls_version                    = "TLS1_2"
      + name                               = (known after apply)
      + nfsv3_enabled                      = false
      + primary_access_key                 = (sensitive value)
      + primary_blob_connection_string     = (sensitive value)
      + primary_blob_endpoint              = (known after apply)
      + primary_blob_host                  = (known after apply)
      + primary_blob_internet_endpoint     = (known after apply)
      + primary_blob_internet_host         = (known after apply)
      + primary_blob_microsoft_endpoint    = (known after apply)
      + primary_blob_microsoft_host        = (known after apply)
      + primary_connection_string          = (sensitive value)
      + primary_dfs_endpoint               = (known after apply)
      + primary_dfs_host                   = (known after apply)
      + primary_dfs_internet_endpoint      = (known after apply)
      + primary_dfs_internet_host          = (known after apply)
      + primary_dfs_microsoft_endpoint     = (known after apply)
      + primary_dfs_microsoft_host         = (known after apply)
      + primary_file_endpoint              = (known after apply)
      + primary_file_host                  = (known after apply)
      + primary_file_internet_endpoint     = (known after apply)
      + primary_file_internet_host         = (known after apply)
      + primary_file_microsoft_endpoint    = (known after apply)
      + primary_file_microsoft_host        = (known after apply)
      + primary_location                   = (known after apply)
      + primary_queue_endpoint             = (known after apply)
      + primary_queue_host                 = (known after apply)
      + primary_queue_microsoft_endpoint   = (known after apply)
      + primary_queue_microsoft_host       = (known after apply)
      + primary_table_endpoint             = (known after apply)
      + primary_table_host                 = (known after apply)
      + primary_table_microsoft_endpoint   = (known after apply)
      + primary_table_microsoft_host       = (known after apply)
      + primary_web_endpoint               = (known after apply)
      + primary_web_host                   = (known after apply)
      + primary_web_internet_endpoint      = (known after apply)
      + primary_web_internet_host          = (known after apply)
      + primary_web_microsoft_endpoint     = (known after apply)
      + primary_web_microsoft_host         = (known after apply)
      + public_network_access_enabled      = true
      + queue_encryption_key_type          = "Service"
      + resource_group_name                = "rg-opella-dev-eastus"
      + secondary_access_key               = (sensitive value)
      + secondary_blob_connection_string   = (sensitive value)
      + secondary_blob_endpoint            = (known after apply)
      + secondary_blob_host                = (known after apply)
      + secondary_blob_internet_endpoint   = (known after apply)
      + secondary_blob_internet_host       = (known after apply)
      + secondary_blob_microsoft_endpoint  = (known after apply)
      + secondary_blob_microsoft_host      = (known after apply)
      + secondary_connection_string        = (sensitive value)
      + secondary_dfs_endpoint             = (known after apply)
      + secondary_dfs_host                 = (known after apply)
      + secondary_dfs_internet_endpoint    = (known after apply)
      + secondary_dfs_internet_host        = (known after apply)
      + secondary_dfs_microsoft_endpoint   = (known after apply)
      + secondary_dfs_microsoft_host       = (known after apply)
      + secondary_file_endpoint            = (known after apply)
      + secondary_file_host                = (known after apply)
      + secondary_file_internet_endpoint   = (known after apply)
      + secondary_file_internet_host       = (known after apply)
      + secondary_file_microsoft_endpoint  = (known after apply)
      + secondary_file_microsoft_host      = (known after apply)
      + secondary_location                 = (known after apply)
      + secondary_queue_endpoint           = (known after apply)
      + secondary_queue_host               = (known after apply)
      + secondary_queue_microsoft_endpoint = (known after apply)
      + secondary_queue_microsoft_host     = (known after apply)
      + secondary_table_endpoint           = (known after apply)
      + secondary_table_host               = (known after apply)
      + secondary_table_microsoft_endpoint = (known after apply)
      + secondary_table_microsoft_host     = (known after apply)
      + secondary_web_endpoint             = (known after apply)
      + secondary_web_host                 = (known after apply)
      + secondary_web_internet_endpoint    = (known after apply)
      + secondary_web_internet_host        = (known after apply)
      + secondary_web_microsoft_endpoint   = (known after apply)
      + secondary_web_microsoft_host       = (known after apply)
      + sftp_enabled                       = false
      + shared_access_key_enabled          = true
      + table_encryption_key_type          = "Service"
      + tags                               = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Project"     = "Opella"
        }

      + blob_properties (known after apply)

      + network_rules (known after apply)

      + queue_properties (known after apply)

      + routing (known after apply)

      + share_properties (known after apply)

      + static_website (known after apply)
    }

  # module.app_env.random_id.storage will be created
  + resource "random_id" "storage" {
      + b64_std     = (known after apply)
      + b64_url     = (known after apply)
      + byte_length = 4
      + dec         = (known after apply)
      + hex         = (known after apply)
      + id          = (known after apply)
    }

  # module.app_env.tls_private_key.ssh will be created
  + resource "tls_private_key" "ssh" {
      + algorithm                     = "RSA"
      + ecdsa_curve                   = "P224"
      + id                            = (known after apply)
      + private_key_openssh           = (sensitive value)
      + private_key_pem               = (sensitive value)
      + private_key_pem_pkcs8         = (sensitive value)
      + public_key_fingerprint_md5    = (known after apply)
      + public_key_fingerprint_sha256 = (known after apply)
      + public_key_openssh            = (known after apply)
      + public_key_pem                = (known after apply)
      + rsa_bits                      = 4096
    }

  # module.app_env.module.vnet.azurerm_subnet.this["sn-compute"] will be created
  + resource "azurerm_subnet" "this" {
      + address_prefixes                              = [
          + "10.0.1.0/24",
        ]
      + default_outbound_access_enabled               = true
      + id                                            = (known after apply)
      + name                                          = "sn-compute"
      + private_endpoint_network_policies             = "Disabled"
      + private_link_service_network_policies_enabled = true
      + resource_group_name                           = "rg-opella-dev-eastus"
      + virtual_network_name                          = "vnet-opella-dev-eastus"
    }

  # module.app_env.module.vnet.azurerm_virtual_network.this will be created
  + resource "azurerm_virtual_network" "this" {
      + address_space                  = [
          + "10.0.0.0/16",
        ]
      + dns_servers                    = []
      + guid                           = (known after apply)
      + id                             = (known after apply)
      + location                       = "eastus"
      + name                           = "vnet-opella-dev-eastus"
      + private_endpoint_vnet_policies = "Disabled"
      + resource_group_name            = "rg-opella-dev-eastus"
      + subnet                         = (known after apply)
      + tags                           = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Project"     = "Opella"
        }
    }

Plan: 10 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + storage_account_name = (known after apply)
  + vm_private_ssh_key   = (sensitive value)
```

### Production Environment
```text
$ cd environments/prod && terraform plan
Acquiring state lock. This may take a few moments...
module.app_env.data.azurerm_client_config.current: Reading...
module.app_env.data.azurerm_client_config.current: Read complete after 0s [id=Y2xpZW50Q29uZmlncy9jbGllbnRJZD0wNGIwNzc5NS04ZGRiLTQ2MWEtYmJlZS0wMmY5ZTFiZjdiNDY7b2JqZWN0SWQ9YjJlMTkzNDUtOTc4MC00NWM4LWI1MTktYjQ3YTAyMTIwMWQ2O3N1YnNjcmlwdGlvbklkPTg4ODlmMjY2LWM4MDUtNGU2ZS04YTc3LTcyMzUzMTNlMzdmZTt0ZW5hbnRJZD1lOTE4MTA2OS1hMGYxLTQ3ZWMtYWYzOS02ODM2OWVkYjcxM2Q=]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following
symbols:
  + create

Terraform will perform the following actions:

  # module.app_env.azurerm_key_vault.this will be created
  + resource "azurerm_key_vault" "this" {
      + access_policy                 = [
          + {
              + object_id          = "b2e19345-9780-45c8-b519-b47a021201d6"
              + secret_permissions = [
                  + "Set",
                  + "Get",
                  + "Delete",
                  + "Purge",
                  + "Recover",
                  + "List",
                ]
              + tenant_id          = "e9181069-a0f1-47ec-af39-68369edb713d"
            },
        ]
      + enable_rbac_authorization     = (known after apply)
      + enabled_for_disk_encryption   = true
      + id                            = (known after apply)
      + location                      = "eastus"
      + name                          = (known after apply)
      + public_network_access_enabled = true
      + purge_protection_enabled      = false
      + rbac_authorization_enabled    = (known after apply)
      + resource_group_name           = "rg-opella-prod-eastus"
      + sku_name                      = "standard"
      + soft_delete_retention_days    = 7
      + tags                          = {
          + "Environment" = "prod"
          + "ManagedBy"   = "Terraform"
          + "Project"     = "Opella"
        }
      + tenant_id                     = "e9181069-a0f1-47ec-af39-68369edb713d"
      + vault_uri                     = (known after apply)

      + contact (known after apply)

      + network_acls (known after apply)
    }

  # module.app_env.azurerm_key_vault_secret.ssh_private_key will be created
  + resource "azurerm_key_vault_secret" "ssh_private_key" {
      + id                      = (known after apply)
      + key_vault_id            = (known after apply)
      + name                    = "vm-ssh-private-key"
      + resource_id             = (known after apply)
      + resource_versionless_id = (known after apply)
      + value                   = (sensitive value)
      + value_wo                = (write-only attribute)
      + version                 = (known after apply)
      + versionless_id          = (known after apply)
    }

  # module.app_env.azurerm_linux_virtual_machine.this will be created
  + resource "azurerm_linux_virtual_machine" "this" {
      + admin_username                                         = "azureadmin"
      + allow_extension_operations                             = (known after apply)
      + bypass_platform_safety_checks_on_user_schedule_enabled = false
      + computer_name                                          = (known after apply)
      + disable_password_authentication                        = (known after apply)
      + disk_controller_type                                   = (known after apply)
      + extensions_time_budget                                 = "PT1H30M"
      + id                                                     = (known after apply)
      + location                                               = "eastus"
      + max_bid_price                                          = -1
      + name                                                   = "vm-opella-prod-eastus"
      + network_interface_ids                                  = (known after apply)
      + os_managed_disk_id                                     = (known after apply)
      + patch_assessment_mode                                  = (known after apply)
      + patch_mode                                             = (known after apply)
      + platform_fault_domain                                  = -1
      + priority                                               = "Regular"
      + private_ip_address                                     = (known after apply)
      + private_ip_addresses                                   = (known after apply)
      + provision_vm_agent                                     = (known after apply)
      + public_ip_address                                      = (known after apply)
      + public_ip_addresses                                    = (known after apply)
      + resource_group_name                                    = "rg-opella-prod-eastus"
      + size                                                   = "Standard_B1s"
      + tags                                                   = {
          + "Environment" = "prod"
          + "ManagedBy"   = "Terraform"
          + "Project"     = "Opella"
        }
      + virtual_machine_id                                     = (known after apply)
      + vm_agent_platform_updates_enabled                      = (known after apply)

      + admin_ssh_key {
          + public_key = (known after apply)
          + username   = "azureadmin"
        }

      + os_disk {
          + caching                   = "ReadWrite"
          + disk_size_gb              = (known after apply)
          + id                        = (known after apply)
          + name                      = (known after apply)
          + storage_account_type      = "Standard_LRS"
          + write_accelerator_enabled = false
        }

      + source_image_reference {
          + offer     = "0001-com-ubuntu-server-jammy"
          + publisher = "Canonical"
          + sku       = "22_04-lts-gen2"
          + version   = "latest"
        }

      + termination_notification (known after apply)
    }

  # module.app_env.azurerm_network_interface.this will be created
  + resource "azurerm_network_interface" "this" {
      + accelerated_networking_enabled = false
      + applied_dns_servers            = (known after apply)
      + id                             = (known after apply)
      + internal_domain_name_suffix    = (known after apply)
      + ip_forwarding_enabled          = false
      + location                       = "eastus"
      + mac_address                    = (known after apply)
      + name                           = "nic-vm-opella-prod-eastus"
      + private_ip_address             = (known after apply)
      + private_ip_addresses           = (known after apply)
      + resource_group_name            = "rg-opella-prod-eastus"
      + tags                           = {
          + "Environment" = "prod"
          + "ManagedBy"   = "Terraform"
          + "Project"     = "Opella"
        }
      + virtual_machine_id             = (known after apply)

      + ip_configuration {
          + gateway_load_balancer_frontend_ip_configuration_id = (known after apply)
          + name                                               = "internal"
          + primary                                            = (known after apply)
          + private_ip_address                                 = (known after apply)
          + private_ip_address_allocation                      = "Dynamic"
          + private_ip_address_version                         = "IPv4"
          + subnet_id                                          = (known after apply)
        }
    }

  # module.app_env.azurerm_resource_group.this will be created
  + resource "azurerm_resource_group" "this" {
      + id       = (known after apply)
      + location = "eastus"
      + name     = "rg-opella-prod-eastus"
      + tags     = {
          + "Environment" = "prod"
          + "ManagedBy"   = "Terraform"
          + "Project"     = "Opella"
        }
    }

  # module.app_env.azurerm_storage_account.this will be created
  + resource "azurerm_storage_account" "this" {
      + access_tier                        = (known after apply)
      + account_kind                       = "StorageV2"
      + account_replication_type           = "GRS"
      + account_tier                       = "Standard"
      + allow_nested_items_to_be_public    = true
      + cross_tenant_replication_enabled   = false
      + default_to_oauth_authentication    = false
      + dns_endpoint_type                  = "Standard"
      + https_traffic_only_enabled         = true
      + id                                 = (known after apply)
      + infrastructure_encryption_enabled  = false
      + is_hns_enabled                     = false
      + large_file_share_enabled           = (known after apply)
      + local_user_enabled                 = true
      + location                           = "eastus"
      + min_tls_version                    = "TLS1_2"
      + name                               = (known after apply)
      + nfsv3_enabled                      = false
      + primary_access_key                 = (sensitive value)
      + primary_blob_connection_string     = (sensitive value)
      + primary_blob_endpoint              = (known after apply)
      + primary_blob_host                  = (known after apply)
      + primary_blob_internet_endpoint     = (known after apply)
      + primary_blob_internet_host         = (known after apply)
      + primary_blob_microsoft_endpoint    = (known after apply)
      + primary_blob_microsoft_host        = (known after apply)
      + primary_connection_string          = (sensitive value)
      + primary_dfs_endpoint               = (known after apply)
      + primary_dfs_host                   = (known after apply)
      + primary_dfs_internet_endpoint      = (known after apply)
      + primary_dfs_internet_host          = (known after apply)
      + primary_dfs_microsoft_endpoint     = (known after apply)
      + primary_dfs_microsoft_host         = (known after apply)
      + primary_file_endpoint              = (known after apply)
      + primary_file_host                  = (known after apply)
      + primary_file_internet_endpoint     = (known after apply)
      + primary_file_internet_host         = (known after apply)
      + primary_file_microsoft_endpoint    = (known after apply)
      + primary_file_microsoft_host        = (known after apply)
      + primary_location                   = (known after apply)
      + primary_queue_endpoint             = (known after apply)
      + primary_queue_host                 = (known after apply)
      + primary_queue_microsoft_endpoint   = (known after apply)
      + primary_queue_microsoft_host       = (known after apply)
      + primary_table_endpoint             = (known after apply)
      + primary_table_host                 = (known after apply)
      + primary_table_microsoft_endpoint   = (known after apply)
      + primary_table_microsoft_host       = (known after apply)
      + primary_web_endpoint               = (known after apply)
      + primary_web_host                   = (known after apply)
      + primary_web_internet_endpoint      = (known after apply)
      + primary_web_internet_host          = (known after apply)
      + primary_web_microsoft_endpoint     = (known after apply)
      + primary_web_microsoft_host         = (known after apply)
      + public_network_access_enabled      = true
      + queue_encryption_key_type          = "Service"
      + resource_group_name                = "rg-opella-prod-eastus"
      + secondary_access_key               = (sensitive value)
      + secondary_blob_connection_string   = (sensitive value)
      + secondary_blob_endpoint            = (known after apply)
      + secondary_blob_host                = (known after apply)
      + secondary_blob_internet_endpoint   = (known after apply)
      + secondary_blob_internet_host       = (known after apply)
      + secondary_blob_microsoft_endpoint  = (known after apply)
      + secondary_blob_microsoft_host      = (known after apply)
      + secondary_connection_string        = (sensitive value)
      + secondary_dfs_endpoint             = (known after apply)
      + secondary_dfs_host                 = (known after apply)
      + secondary_dfs_internet_endpoint    = (known after apply)
      + secondary_dfs_internet_host        = (known after apply)
      + secondary_dfs_microsoft_endpoint   = (known after apply)
      + secondary_dfs_microsoft_host       = (known after apply)
      + secondary_file_endpoint            = (known after apply)
      + secondary_file_host                = (known after apply)
      + secondary_file_internet_endpoint   = (known after apply)
      + secondary_file_internet_host       = (known after apply)
      + secondary_file_microsoft_endpoint  = (known after apply)
      + secondary_file_microsoft_host      = (known after apply)
      + secondary_location                 = (known after apply)
      + secondary_queue_endpoint           = (known after apply)
      + secondary_queue_host               = (known after apply)
      + secondary_queue_microsoft_endpoint = (known after apply)
      + secondary_queue_microsoft_host     = (known after apply)
      + secondary_table_endpoint           = (known after apply)
      + secondary_table_host               = (known after apply)
      + secondary_table_microsoft_endpoint = (known after apply)
      + secondary_table_microsoft_host     = (known after apply)
      + secondary_web_endpoint             = (known after apply)
      + secondary_web_host                 = (known after apply)
      + secondary_web_internet_endpoint    = (known after apply)
      + secondary_web_internet_host        = (known after apply)
      + secondary_web_microsoft_endpoint   = (known after apply)
      + secondary_web_microsoft_host       = (known after apply)
      + sftp_enabled                       = false
      + shared_access_key_enabled          = true
      + table_encryption_key_type          = "Service"
      + tags                               = {
          + "Environment" = "prod"
          + "ManagedBy"   = "Terraform"
          + "Project"     = "Opella"
        }

      + blob_properties (known after apply)

      + network_rules (known after apply)

      + queue_properties (known after apply)

      + routing (known after apply)

      + share_properties (known after apply)

      + static_website (known after apply)
    }

  # module.app_env.random_id.storage will be created
  + resource "random_id" "storage" {
      + b64_std     = (known after apply)
      + b64_url     = (known after apply)
      + byte_length = 4
      + dec         = (known after apply)
      + hex         = (known after apply)
      + id          = (known after apply)
    }

  # module.app_env.tls_private_key.ssh will be created
  + resource "tls_private_key" "ssh" {
      + algorithm                     = "RSA"
      + ecdsa_curve                   = "P224"
      + id                            = (known after apply)
      + private_key_openssh           = (sensitive value)
      + private_key_pem               = (sensitive value)
      + private_key_pem_pkcs8         = (sensitive value)
      + public_key_fingerprint_md5    = (known after apply)
      + public_key_fingerprint_sha256 = (known after apply)
      + public_key_openssh            = (known after apply)
      + public_key_pem                = (known after apply)
      + rsa_bits                      = 4096
    }

  # module.app_env.module.vnet.azurerm_subnet.this["sn-compute"] will be created
  + resource "azurerm_subnet" "this" {
      + address_prefixes                              = [
          + "10.1.1.0/24",
        ]
      + default_outbound_access_enabled               = true
      + id                                            = (known after apply)
      + name                                          = "sn-compute"
      + private_endpoint_network_policies             = "Disabled"
      + private_link_service_network_policies_enabled = true
      + resource_group_name                           = "rg-opella-prod-eastus"
      + virtual_network_name                          = "vnet-opella-prod-eastus"
    }

  # module.app_env.module.vnet.azurerm_virtual_network.this will be created
  + resource "azurerm_virtual_network" "this" {
      + address_space                  = [
          + "10.1.0.0/16",
        ]
      + dns_servers                    = []
      + guid                           = (known after apply)
      + id                             = (known after apply)
      + location                       = "eastus"
      + name                           = "vnet-opella-prod-eastus"
      + private_endpoint_vnet_policies = "Disabled"
      + resource_group_name            = "rg-opella-prod-eastus"
      + subnet                         = (known after apply)
      + tags                           = {
          + "Environment" = "prod"
          + "ManagedBy"   = "Terraform"
          + "Project"     = "Opella"
        }
    }

Plan: 10 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + storage_account_name = (known after apply)
  + vm_private_ssh_key   = (sensitive value)
```
Thank you!