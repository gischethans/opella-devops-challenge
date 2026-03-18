variable "environment" {
  description = "The environment name (e.g., dev, prod)"
  type        = string
}

variable "location" {
  description = "The Azure region"
  type        = string
  default     = "eastus"
}

variable "vnet_address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "vm_admin_username" {
  type    = string
  default = "azureadmin"
}

variable "tags" {
  description = "A mapping of tags to assign to the resources."
  type        = map(string)
  default     = {}
}
