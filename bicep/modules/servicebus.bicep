// Service Bus resources module - Namespace, Topic, and Subscription

@description('Location for all resources')
param location string

@description('Base name with dashes for resource naming')
param baseName string

// Service Bus Namespace
resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: 'sb-${baseName}'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// Service Bus Topic
resource serviceBusTopic 'Microsoft.ServiceBus/namespaces/topics@2022-10-01-preview' = {
  parent: serviceBusNamespace
  name: 'sbt-${baseName}'
  properties: {
    enablePartitioning: true
  }
}

// Service Bus Subscription
resource serviceBusSubscription 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2022-10-01-preview' = {
  parent: serviceBusTopic
  name: 'sbts-${baseName}'
  properties: {
    maxDeliveryCount: 1
  }
}

// Outputs
output namespaceName string = serviceBusNamespace.name
output namespaceId string = serviceBusNamespace.id
output topicName string = serviceBusTopic.name
output topicId string = serviceBusTopic.id
output subscriptionName string = serviceBusSubscription.name
