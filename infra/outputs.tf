output "resource_group_name" {
  description = "Created Azure resource group."
  value       = azurerm_resource_group.this.name
}

output "storage_account_name" {
  description = "Created Azure Storage account."
  value       = azurerm_storage_account.this.name
}

output "storage_container_name" {
  description = "Created private Blob container."
  value       = azurerm_storage_container.artifacts.name
}