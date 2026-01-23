resource "azurerm_resource_group" "rg" {
  name     = provider::namep::namestring("azurerm_resource_group", data.namep_configuration.main.configuration, { name = "main" })
  location = "West Europe"
}

resource "azurerm_container_registry" "acr" {
  name                = provider::namep::namestring("azurerm_container_registry", data.namep_configuration.main.configuration, { name = "main" })
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Premium"
  admin_enabled       = false
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = provider::namep::namestring("azurerm_log_analytics_workspace", data.namep_configuration.main.configuration, { name = "main" })
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "main" {
  name                = provider::namep::namestring("azurerm_application_insights", data.namep_configuration.main.configuration, { name = "main" })
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "Node.JS"
}