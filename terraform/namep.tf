data "namep_azure_locations" "main" {}

data "namep_azure_caf_types" "main" {}

data "namep_configuration" "main" {
  variable_maps = data.namep_azure_locations.main.location_maps
  types         = data.namep_azure_caf_types.main.types
  formats = {
    azure_nodashes                                  = "#{SLUG}#{APP}#{ENV}#{LOCS[LOC]}#{NAME}#{SALT}"
    azure_dashes                                    = "#{SLUG}-#{APP}-#{ENV}-#{LOCS[LOC]}-#{NAME}#{-SALT}"
    azure_eventgrid_system_topic                    = "egst-#{APP}-#{ENV}-#{LOCS[LOC]}-#{NAME}#{-SALT}"
    azure_eventgrid_system_topic_event_subscription = "egsts-#{APP}-#{ENV}-#{LOCS[LOC]}-#{NAME}#{-SALT}"
  }

  variables = {
    name = var.name
    loc  = "westeurope"
    app  = "rdcyb"
    env  = "demo"
    salt = var.salt
  }
}
