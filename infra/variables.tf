variable "location" {
  description = "Azure region used for deployed resources."
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Name of the Azure resource group."
  type        = string
  default     = "rg-platform-automation-lab"
}

variable "storage_account_name" {
  description = "Globally unique Azure Storage account name."
  type        = string

  validation {
    condition = (
      length(var.storage_account_name) >= 3 &&
      length(var.storage_account_name) <= 24 &&
      can(regex("^[a-z0-9]+$", var.storage_account_name))
    )

    error_message = "Storage account name must be 3-24 lowercase alphanumeric characters."
  }
}