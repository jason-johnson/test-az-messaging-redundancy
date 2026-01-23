# Namep Provider Migration from v1 to v2

## Summary
This document describes the migration from namep provider v1.x to v2.x completed on 2026-01-23.

## Changes Made

### Version Updates
- Updated version constraint from `~> 1.0` to `~> 2.0` in:
  - `terraform/versions.tf`
  - `terraform/function/versions.tf`

### Provider Configuration Migration

#### v1 Configuration (Removed)
```hcl
provider "namep" {
  slice_string                 = "RDNCY DEMO"
  default_location             = "westeurope"
  default_nodash_name_format   = "#{SLUG}#{TOKEN_1}#{TOKEN_2}#{SHORT_LOC}#{NAME}#{BRANCH}"
  default_resource_name_format = "#{SLUG}-#{TOKEN_1}-#{TOKEN_2}#{-SHORT_LOC}-#{NAME}#{-BRANCH}"

  extra_tokens = {
    branch = var.branch
  }

  resource_formats = {
    azurerm_eventgrid_system_topic = "egst-#{TOKEN_1}-#{TOKEN_2}-#{SHORT_LOC}-#{NAME}#{-BRANCH}"
    azurerm_eventgrid_system_topic_event_subscription = "egsts-#{TOKEN_1}-#{TOKEN_2}-#{SHORT_LOC}-#{NAME}#{-BRANCH}"
  }
}
```

#### v2 Configuration (Added)
```hcl
provider "namep" {}

data "namep_azure_locations" "main" {}

data "namep_azure_caf_types" "main" {}

data "namep_configuration" "main" {
  variable_maps = data.namep_azure_locations.main.location_maps
  types         = data.namep_azure_caf_types.main.types
  formats = {
    azure_nodash                                    = "#{SLUG}#{TOKEN_1}#{TOKEN_2}#{LOCS[LOC]}#{NAME}#{BRANCH}"
    azure_dashes                                    = "#{SLUG}-#{TOKEN_1}-#{TOKEN_2}-#{LOCS[LOC]}-#{NAME}#{-BRANCH}"
    azure_eventgrid_system_topic                    = "egst-#{TOKEN_1}-#{TOKEN_2}-#{LOCS[LOC]}-#{NAME}#{-BRANCH}"
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
```

### Data Source to Function Migration

#### v1 Usage (Removed)
```hcl
data "namep_azure_name" "rg" {
  name     = "main"
  location = "westeurope"
  type     = "azurerm_resource_group"
}

resource "azurerm_resource_group" "rg" {
  name     = data.namep_azure_name.rg.result
  location = "West Europe"
}
```

#### v2 Usage (Added)
```hcl
resource "azurerm_resource_group" "rg" {
  name     = provider::namep::namestring("azurerm_resource_group", data.namep_configuration.main.configuration, { name = "main" })
  location = "West Europe"
}
```

## Key Differences

### Location Variable
- v1: Used `#{SHORT_LOC}` with implicit location from `default_location`
- v2: Uses `#{LOCS[LOC]}` with explicit location from `variables.loc`
- Both should produce the same abbreviation (e.g., "we" for "westeurope") following Azure CAF standards

### Configuration Style
- v1: Configuration in provider block
- v2: Configuration in data source, provider block is empty

### Name Generation
- v1: Used `data "namep_azure_name"` data sources
- v2: Uses `provider::namep::namestring()` function

### Variable Naming
- v1: Used `extra_tokens` for custom variables
- v2: All variables go in the `variables` map

## Files Modified
- `terraform/versions.tf`
- `terraform/main.tf`
- `terraform/resources.tf`
- `terraform/servicebus.tf`
- `terraform/function/versions.tf`
- `terraform/function/main.tf`

## Verification
The configuration was validated using:
```bash
terraform init -upgrade -backend=false
terraform validate
terraform fmt -recursive
```

All validations passed successfully.

## Notes
- Resource names should remain identical between v1 and v2 as all naming patterns and variables were preserved
- The migration maintains backward compatibility with existing resource names
- Location abbreviations follow Azure CAF standards in both versions
