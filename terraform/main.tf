terraform {
  backend "azurerm" {
    use_azuread_auth = true
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "namep" {
  slice_string                 = "RDNCY DEMO"
  default_location             = "westeurope"
  default_nodash_name_format   = "#{SLUG}#{TOKEN_1}#{TOKEN_2}#{SHORT_LOC}#{NAME}#{SALT}"
  default_resource_name_format = "#{SLUG}-#{TOKEN_1}-#{TOKEN_2}-#{SHORT_LOC}-#{NAME}#{-SALT}"

  extra_tokens = {
    salt = var.salt
  }

  resource_formats = {
    azurerm_eventgrid_system_topic = "egst-#{TOKEN_1}-#{TOKEN_2}-#{SHORT_LOC}-#{NAME}#{-SALT}"
    azurerm_eventgrid_system_topic_event_subscription = "egsts-#{TOKEN_1}-#{TOKEN_2}-#{SHORT_LOC}-#{NAME}#{-SALT}"
  }
}
