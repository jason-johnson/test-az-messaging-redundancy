// Shared resources module - Container Registry, Log Analytics, and Application Insights

@description('Location for all resources')
param location string

@description('Base name with dashes for resource naming')
param baseName string

@description('Base name without dashes for resources that don\'t support dashes')
param baseNameNoDashes string

@description('Unique suffix for globally unique names')
param uniqueSuffix string

// Container Registry (globally unique name required, no dashes allowed)
resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: 'cr${baseNameNoDashes}${uniqueSuffix}'
  location: location
  sku: {
    name: 'Premium'
  }
  properties: {
    adminUserEnabled: false
  }
}

// Log Analytics Workspace
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: 'log-${baseName}'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

// Application Insights
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'appi-${baseName}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'Node.JS'
    WorkspaceResourceId: logAnalytics.id
  }
}

// Outputs
output acrName string = acr.name
output acrLoginServer string = acr.properties.loginServer
output acrId string = acr.id
output appInsightsConnectionString string = appInsights.properties.ConnectionString
output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
output logAnalyticsId string = logAnalytics.id
