# Azure Messaging Redundancy - Bicep Deployment

This folder contains Bicep templates converted from the Terraform configuration for deploying Azure messaging redundancy infrastructure.

## Architecture

The deployment creates the following Azure resources:

- **Resource Group** - Container for all resources
- **Container Registry (ACR)** - Premium tier for storing container images
- **Log Analytics Workspace** - For centralized logging
- **Application Insights** - For application monitoring
- **Service Bus Namespace** - Standard tier with system-assigned identity
- **Service Bus Topic** - With partitioning enabled
- **Service Bus Subscription** - For message consumption
- **Two Function Apps** (main and sec) - Each with:
  - Storage Account
  - App Service Plan (Elastic Premium EP1)
  - Linux Function App with container support
  - Role assignments for ACR pull and Service Bus access

## File Structure

```
bicep/
├── main.bicep              # Main deployment file (subscription scope)
├── parameters.json         # Parameter file for deployment
├── README.md              # This file
└── modules/
    ├── shared-resources.bicep  # ACR, Log Analytics, App Insights
    ├── servicebus.bicep        # Service Bus resources
    └── function.bicep          # Function App module (reusable)
```

## Prerequisites

- Azure CLI installed and configured
- Azure subscription with appropriate permissions
- Logged in to Azure (`az login`)

## Deployment

### Using Azure CLI

```bash
# Set your subscription
az account set --subscription "<your-subscription-id>"

# Deploy at subscription scope
az deployment sub create \
  --location westeurope \
  --template-file main.bicep \
  --parameters parameters.json
```

### Using Azure CLI with custom parameters

```bash
az deployment sub create \
  --location westeurope \
  --template-file main.bicep \
  --parameters name=myapp salt=prod
```

### What-If Deployment (Preview changes)

```bash
az deployment sub what-if \
  --location westeurope \
  --template-file main.bicep \
  --parameters parameters.json
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `name` | string | `main` | Base name for resources |
| `salt` | string | `""` | Optional salt for name uniqueness |
| `location` | string | `westeurope` | Azure region for deployment |
| `app` | string | `rdcy` | Application abbreviation |
| `env` | string | `demo` | Environment abbreviation |

## Outputs

| Output | Description |
|--------|-------------|
| `rgName` | Name of the resource group |
| `mainFuncStorageAccountName` | Storage account name for main function |
| `mainFuncServicePlanName` | App service plan name for main function |
| `mainFuncName` | Main function app name |
| `acrName` | Container registry name |
| `acrUrl` | Container registry login server URL |

## Naming Convention

Resources follow Azure CAF naming conventions:
- Pattern: `{resource-prefix}-{app}-{env}-{location}-{name}[-{salt}]`
- Example: `func-rdcy-demo-weu-main`

Resources that don't support dashes use a condensed format with a unique suffix for global uniqueness.

## Notes

- The deployment targets subscription scope to create the resource group
- Function Apps use managed identity for ACR access (no admin credentials)
- Service Bus connections use managed identity authentication
- The unique suffix ensures globally unique names for storage accounts and container registry
