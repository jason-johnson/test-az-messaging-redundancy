data "namep_azure_locations" "main" {}

data "namep_azure_caf_types" "main" {}

data "namep_configuration" "main" {
  variable_maps = data.namep_azure_locations.main.location_maps
  types         = data.namep_azure_caf_types.main.types
  formats = {
    azure_nodash = "#{SLUG}#{TOKEN_1}#{TOKEN_2}#{LOCS[LOC]}#{NAME}#{BRANCH}"
    azure_dashes = "#{SLUG}-#{TOKEN_1}-#{TOKEN_2}-#{LOCS[LOC]}-#{NAME}#{-BRANCH}"
  }

  variables = {
    name    = var.name
    loc     = "westeurope"
    slug    = "RDNCY DEMO"
    token_1 = ""
    token_2 = ""
    branch  = ""
  }
}

resource "azurerm_storage_account" "main" {
  name                     = provider::namep::namestring("azurerm_storage_account", data.namep_configuration.main.configuration, { name = var.name })
  resource_group_name      = var.resource_group_name
  location                 = var.resource_group_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "main" {
  name                = provider::namep::namestring("azurerm_app_service_plan", data.namep_configuration.main.configuration, { name = var.name })
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  os_type             = "Linux"
  sku_name            = "EP1"
}

resource "azurerm_linux_function_app" "main" {
  name                = provider::namep::namestring("azurerm_function_app", data.namep_configuration.main.configuration, { name = var.name })
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location

  storage_account_name       = azurerm_storage_account.main.name
  storage_account_access_key = azurerm_storage_account.main.primary_access_key
  service_plan_id            = azurerm_service_plan.main.id

  site_config {
    application_insights_connection_string  = var.app_insights_connection_string
    application_insights_key                = var.app_insights_instrumentation_key
    container_registry_use_managed_identity = true
    application_stack {
      docker {
        registry_url = var.acr_login_server
        image_name   = "message-func"
        image_tag    = "latest"
      }
    }

    app_service_logs {
      disk_quota_mb         = 35
      retention_period_days = 5
    }

  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "ServiceBusConnection__fullyQualifiedNamespace" : "${var.servicebus_namespace_name}.servicebus.windows.net"
    "FULLY_QUALIFIED_NAMESPACE" = "${var.servicebus_namespace_name}.servicebus.windows.net"
    "TOPIC_NAME" = var.servicebus_topic_name
    "SUBSCRIPTION_NAME" = var.servicebus_subscription_name
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "fun2acr" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_linux_function_app.main.identity[0].principal_id
}

resource "azurerm_role_assignment" "fun2sb" {
  scope                = var.servicebus_topic_id
  role_definition_name = "Azure Service Bus Data Owner"
  principal_id         = azurerm_linux_function_app.main.identity[0].principal_id
}
