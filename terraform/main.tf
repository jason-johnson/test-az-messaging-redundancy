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
    azure_nodash                                    = "#{SLUG}#{APP}#{ENV}#{LOCS[LOC]}#{NAME}#{BRANCH}"
    azure_dashes                                    = "#{SLUG}-#{APP}-#{ENV}-#{LOCS[LOC]}-#{NAME}#{-BRANCH}"
    azure_eventgrid_system_topic                    = "egst-#{APP}-#{ENV}-#{LOCS[LOC]}-#{NAME}#{-BRANCH}"
    azure_eventgrid_system_topic_event_subscription = "egsts-#{APP}-#{ENV}-#{LOCS[LOC]}-#{NAME}#{-BRANCH}"
  }

  variables = {
    name   = "main"
    loc    = "westeurope"
    app    = "RDNCY"
    env    = "DEMO"
    branch = var.branch
  }
}
