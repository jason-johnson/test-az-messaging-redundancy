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

provider "namep" {}

data "namep_azure_locations" "main" {}

data "namep_azure_caf_types" "main" {}

data "namep_configuration" "main" {
  variable_maps = data.namep_azure_locations.main.location_maps
  types         = data.namep_azure_caf_types.main.types
  formats = {
    azure_nodash  = "#{SLUG}#{TOKEN_1}#{TOKEN_2}#{LOCS[LOC]}#{NAME}#{BRANCH}"
    azure_dashes  = "#{SLUG}-#{TOKEN_1}-#{TOKEN_2}-#{LOCS[LOC]}-#{NAME}#{-BRANCH}"
    azure_eventgrid_system_topic = "egst-#{TOKEN_1}-#{TOKEN_2}-#{LOCS[LOC]}-#{NAME}#{-BRANCH}"
    azure_eventgrid_system_topic_event_subscription = "egsts-#{TOKEN_1}-#{TOKEN_2}-#{LOCS[LOC]}-#{NAME}#{-BRANCH}"
  }

  variables = {
    name    = "main"
    loc     = "westeurope"
    slug    = "RDNCY DEMO"
    token_1 = ""
    token_2 = ""
    branch  = var.branch
  }
}
