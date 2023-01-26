data "namep_azure_name" "rg" {
  name     = "main"
  location = "westeurope"
  type     = "azurerm_resource_group"
}

resource "azurerm_resource_group" "rg" {
  name     = data.namep_azure_name.rg.result
  location = "West Europe"
}

data "namep_azure_name" "acr" {
  name     = "main"
  location = "westeurope"
  type     = "azurerm_container_registry"
}

resource "azurerm_container_registry" "acr" {
  name                = data.namep_azure_name.acr.result
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Premium"
  admin_enabled       = false
}

data "namep_azure_name" "ws" {
  name     = var.name
  location = "westeurope"
  type     = "azurerm_log_analytics_workspace"
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = data.namep_azure_name.ws.result
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

data "namep_azure_name" "ai" {
  name     = var.name
  location = "westeurope"
  type     = "azurerm_application_insights"
}

resource "azurerm_application_insights" "main" {
  name                = data.namep_azure_name.ai.result
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "Node.JS"
}