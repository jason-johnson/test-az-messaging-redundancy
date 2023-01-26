data "namep_azure_name" "sbns" {
  name     = "main"
  location = "westeurope"
  type     = "azurerm_servicebus_namespace"
}

resource "azurerm_servicebus_namespace" "main" {
  name                = data.namep_azure_name.sbns.result
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  identity {
    type = "SystemAssigned"
  }
}

data "namep_azure_name" "sbt" {
  name     = "main"
  location = "westeurope"
  type     = "azurerm_servicebus_topic"
}

resource "azurerm_servicebus_topic" "main" {
  name         = data.namep_azure_name.sbt.result
  namespace_id = azurerm_servicebus_namespace.main.id

  enable_partitioning = true
}

data "namep_azure_name" "sbts" {
  name     = "main"
  location = "westeurope"
  type     = "azurerm_servicebus_subscription"
}

resource "azurerm_servicebus_subscription" "main" {
  name               = data.namep_azure_name.sbts.result
  topic_id           = azurerm_servicebus_topic.main.id
  max_delivery_count = 1
}