# Azure Virtual Network (VNET) Terraform Module

This module deploys an Azure Virtual Network (VNET) with optional subnets, Network Security Group (NSG) associations, Route Table associations, and subnet delegations.

It is designed to provide a flexible and reusable baseline for Azure networking setups, enabling multi-environment provisioning (e.g., Development, Staging, Production) without repeating code.

## Usage Example

```hcl
module "vnet" {
  source = "./modules/vnet"

  vnet_name           = "vnet-dev-eastus"
  resource_group_name = "rg-network-dev"
  location            = "eastus"
  address_space       = ["10.0.0.0/16"]

  subnets = {
    "snet-web" = {
      address_prefixes = ["10.0.1.0/24"]
    }
    "snet-db" = {
      address_prefixes          = ["10.0.2.0/24"]
      network_security_group_id = "/subscriptions/.../networkSecurityGroups/nsg-db"
      delegation = {
        name = "mysql-delegation"
        service_delegation = {
          name = "Microsoft.DBforMySQL/flexibleServers"
        }
      }
    }
  }

  tags = {
    Environment = "dev"
    Project     = "Opella"
  }
}
```

## Features

- **Virtual Network Generation**: Readily deploy a VNET with standard configuration.
- **Dynamic Subnet Provisioning**: Subnets are passed as a map, meaning any number of subnets can be provisioned in the same module call.
- **Security Group Integration**: Optional dynamic association of existing NSGs to the deployed subnets.
- **Route Table Association**: Option to control routing by dynamically associating Route Tables to subnets.
- **Service Delegation**: Easily delegate subnets to integrated Azure services using dynamic blocks.

## Automated Documentation

You can use [terraform-docs](https://terraform-docs.io/) to automatically generate the markdown documentation for inputs, outputs, and requirements from the source code.
For example:
```bash
terraform-docs markdown table . > README.md
```
