output "rg_name" {
  description = "Name of project resource group"
  value       = azurerm_resource_group.rg.name
}
output "acr_name" {
  description = "Name of project azure container registry"
  value       = azurerm_container_registry.acr.name
}

output "acr_url" {
  description = "Url of project azure container registry"
  value       = azurerm_container_registry.acr.login_server
}