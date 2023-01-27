output "rg_name" {
  description = "Name of project resource group"
  value       = azurerm_resource_group.rg.name
}

output "main_func_sa_name" {
  description = "Name of project storage account"
  value       = module.main-function.sa_name
}

output "main_func_sp_name" {
  description = "Name of project service plan"
  value       = module.main-function.sp_name
}

output "main_fun_name" {
  description = "Name of project azure function app"
  value       = module.main-function.function_name
}

output "acr_name" {
  description = "Name of project azure container registry"
  value       = azurerm_container_registry.acr.name
}

output "acr_url" {
  description = "Url of project azure container registry"
  value       = azurerm_container_registry.acr.login_server
}