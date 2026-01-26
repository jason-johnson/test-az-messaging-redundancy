// Function App module - Storage Account, App Service Plan, and Linux Function App

@description('Location for all resources')
param location string

@description('Function name identifier (e.g., main, sec)')
param functionName string

@description('Base name with dashes for resource naming')
param baseName string

@description('Unique suffix for globally unique names')
param uniqueSuffix string

@description('Application Insights connection string')
param appInsightsConnectionString string

@description('Application Insights instrumentation key')
param appInsightsInstrumentationKey string

@description('ACR login server URL')
param acrLoginServer string

@description('ACR resource ID')
param acrId string

@description('Service Bus namespace name')
param serviceBusNamespaceName string

@description('Service Bus topic resource ID')
param serviceBusTopicId string

@description('Service Bus topic name')
param serviceBusTopicName string

@description('Service Bus subscription name')
param serviceBusSubscriptionName string

// Generate a short unique suffix for storage account (max 24 chars total)
var storageAccountName = take('st${functionName}${uniqueSuffix}', 24)

// Storage Account for Function App - no shared key access needed
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowSharedKeyAccess: false // Using managed identity instead
  }
}

// App Service Plan (Elastic Premium for Function Apps)
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: 'asp-${baseName}-${functionName}'
  location: location
  kind: 'linux'
  sku: {
    name: 'EP1'
    tier: 'ElasticPremium'
  }
  properties: {
    reserved: true // Required for Linux
  }
}

// Linux Function App - using managed identity for storage
resource functionApp 'Microsoft.Web/sites@2023-01-01' = {
  name: 'func-${baseName}-${functionName}'
  location: location
  kind: 'functionapp,linux,container'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOCKER|${acrLoginServer}/message-func:latest'
      acrUseManagedIdentityCreds: true
      appSettings: [
        {
          // Use identity-based connection for AzureWebJobsStorage
          name: 'AzureWebJobsStorage__accountName'
          value: storageAccount.name
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsightsInstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightsConnectionString
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'ServiceBusConnection__fullyQualifiedNamespace'
          value: '${serviceBusNamespaceName}.servicebus.windows.net'
        }
        {
          name: 'FULLY_QUALIFIED_NAMESPACE'
          value: '${serviceBusNamespaceName}.servicebus.windows.net'
        }
        {
          name: 'TOPIC_NAME'
          value: serviceBusTopicName
        }
        {
          name: 'SUBSCRIPTION_NAME'
          value: serviceBusSubscriptionName
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${acrLoginServer}'
        }
      ]
      httpLoggingEnabled: true
      logsDirectorySizeLimit: 35
    }
  }
}

// Role Assignment - Function App to Storage Account (Storage Blob Data Owner)
resource storageBlobRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, functionApp.id, 'storageblobowner')
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b') // Storage Blob Data Owner
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Role Assignment - Function App to Storage Account (Storage Account Contributor - for queues/tables)
resource storageAccountContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, functionApp.id, 'storageaccountcontributor')
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '17d1049b-9a84-46fb-8f53-869881c3d3ab') // Storage Account Contributor
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Role Assignment - Function App to Storage Account (Storage Queue Data Contributor)
resource storageQueueRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, functionApp.id, 'storagequeuecontributor')
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '974c5e8b-45b9-4653-ba55-5f855dd0fb88') // Storage Queue Data Contributor
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Role Assignment - Function App to Storage Account (Storage Table Data Contributor)
resource storageTableRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, functionApp.id, 'storagetablecontributor')
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3') // Storage Table Data Contributor
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Role Assignment - Function App to ACR (AcrPull)
resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acrId, functionApp.id, 'acrpull')
  scope: resourceGroup()
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d') // AcrPull
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Role Assignment - Function App to Service Bus Topic (Azure Service Bus Data Owner)
resource serviceBusRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(serviceBusTopicId, functionApp.id, 'servicebusowner')
  scope: resourceGroup()
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '090c5cfd-751d-490a-894a-3ce6f1109419') // Azure Service Bus Data Owner
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Outputs
output storageAccountName string = storageAccount.name
output servicePlanName string = appServicePlan.name
output functionAppName string = functionApp.name
output functionAppPrincipalId string = functionApp.identity.principalId
