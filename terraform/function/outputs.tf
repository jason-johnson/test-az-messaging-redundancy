output "sa_name" {
    value = azurerm_storage_account.main.name
}

output "sp_name" {
  value = azurerm_service_plan.main.name
}

output "function_name" {
    value = azurerm_linux_function_app.main.name
}