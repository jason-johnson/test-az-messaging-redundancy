// Main Bicep deployment file for Azure Messaging Redundancy Demo
// Converts the Terraform configuration to Bicep

targetScope = 'subscription'

@description('Base name for resources')
param name string = 'main'

@description('Optional salt for use in the name')
param salt string = ''

@description('Location for all resources')
param location string = 'westeurope'

@description('Application abbreviation')
param app string = 'rdcy'

@description('Environment abbreviation')
param env string = 'demo'

// Generate a unique suffix for globally unique names
var uniqueSuffix = uniqueString(subscription().subscriptionId, name, salt)
var locationShort = 'weu'

// Naming convention variables
var baseName = '${app}-${env}-${locationShort}-${name}${empty(salt) ? '' : '-${salt}'}'
var baseNameNoDashes = '${app}${env}${locationShort}${name}${salt}'

// Resource Group
resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-${baseName}'
  location: location
}

// Deploy shared resources
module sharedResources 'modules/shared-resources.bicep' = {
  scope: rg
  name: 'shared-resources'
  params: {
    location: location
    baseName: baseName
    baseNameNoDashes: baseNameNoDashes
    uniqueSuffix: uniqueSuffix
  }
}

// Deploy Service Bus resources
module serviceBus 'modules/servicebus.bicep' = {
  scope: rg
  name: 'servicebus'
  params: {
    location: location
    baseName: baseName
  }
}

// Deploy main function app
module mainFunction 'modules/function.bicep' = {
  scope: rg
  name: 'main-function'
  params: {
    location: location
    functionName: 'main'
    baseName: baseName
    uniqueSuffix: uniqueSuffix
    appInsightsConnectionString: sharedResources.outputs.appInsightsConnectionString
    appInsightsInstrumentationKey: sharedResources.outputs.appInsightsInstrumentationKey
    acrLoginServer: sharedResources.outputs.acrLoginServer
    acrId: sharedResources.outputs.acrId
    serviceBusNamespaceName: serviceBus.outputs.namespaceName
    serviceBusTopicId: serviceBus.outputs.topicId
    serviceBusTopicName: serviceBus.outputs.topicName
    serviceBusSubscriptionName: serviceBus.outputs.subscriptionName
  }
}

// Deploy second function app
module secondFunction 'modules/function.bicep' = {
  scope: rg
  name: 'second-function'
  params: {
    location: location
    functionName: 'sec'
    baseName: baseName
    uniqueSuffix: uniqueSuffix
    appInsightsConnectionString: sharedResources.outputs.appInsightsConnectionString
    appInsightsInstrumentationKey: sharedResources.outputs.appInsightsInstrumentationKey
    acrLoginServer: sharedResources.outputs.acrLoginServer
    acrId: sharedResources.outputs.acrId
    serviceBusNamespaceName: serviceBus.outputs.namespaceName
    serviceBusTopicId: serviceBus.outputs.topicId
    serviceBusTopicName: serviceBus.outputs.topicName
    serviceBusSubscriptionName: serviceBus.outputs.subscriptionName
  }
}

// Outputs
output rgName string = rg.name
output mainFuncStorageAccountName string = mainFunction.outputs.storageAccountName
output mainFuncServicePlanName string = mainFunction.outputs.servicePlanName
output mainFuncName string = mainFunction.outputs.functionAppName
output acrName string = sharedResources.outputs.acrName
output acrUrl string = sharedResources.outputs.acrLoginServer
