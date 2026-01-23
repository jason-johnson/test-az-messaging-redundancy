resource "azurerm_servicebus_namespace" "main" {
  name                = provider::namep::namestring("azurerm_servicebus_namespace", data.namep_configuration.main.configuration, { name = "main" })
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_servicebus_topic" "main" {
  name         = provider::namep::namestring("azurerm_servicebus_topic", data.namep_configuration.main.configuration, { name = "main" })
  namespace_id = azurerm_servicebus_namespace.main.id

  enable_partitioning = true
}

resource "azurerm_servicebus_subscription" "main" {
  name               = provider::namep::namestring("azurerm_servicebus_subscription", data.namep_configuration.main.configuration, { name = "main" })
  topic_id           = azurerm_servicebus_topic.main.id
  max_delivery_count = 1
}