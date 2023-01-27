
module "main-function" {
    source = "./function"
    name = "main"
    resource_group_name = azurerm_resource_group.rg.name
    resource_group_location = azurerm_resource_group.rg.location
    app_insights_connection_string = azurerm_application_insights.main.connection_string
    app_insights_instrumentation_key = azurerm_application_insights.main.instrumentation_key
    acr_login_server = azurerm_container_registry.acr.login_server
    acr_id = azurerm_container_registry.acr.id
    servicebus_namespace_name = azurerm_servicebus_namespace.main.name
    servicebus_topic_id = azurerm_servicebus_topic.main.id
}

#module "second-function" {
#    source = "./function"
#    name = "second"
#    resource_group_name = azurerm_resource_group.rg.name
#    resource_group_location = azurerm_resource_group.rg.location
#    app_insights_connection_string = azurerm_application_insights.main.connection_string
#    app_insights_instrumentation_key = azurerm_application_insights.main.instrumentation_key
#    acr_login_server = azurerm_container_registry.acr.login_server
#    acr_id = azurerm_container_registry.acr.id
#    servicebus_namespace_name = azurerm_servicebus_namespace.main.name
#    servicebus_topic_id = azurerm_servicebus_topic.main.id
#}