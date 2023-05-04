output "rg_name" {
  description = "Name of project resource group"
  value       = azurerm_resource_group.rg.name
}
output "acr_name" {
  description = "Name of project azure container registry"
  value       = azurerm_container_registry.acr.name
}

output "acr_url" {
  description = "Url of project azure container registry"
  value       = azurerm_container_registry.acr.login_server
}

#outputs.tf - https://azure.github.io/AKS-Construction/?secure=low&deploy.deployItemKey=deployTf&deploy.rg=remove-this-later&deploy.apiips=&deploy.clusterName=do-not-use&cluster.AksPaidSkuForSLA=false&cluster.agentCount=1&cluster.maxCount=20&cluster.vmSize=Standard_D2s_v3&cluster.osDiskType=Managed&cluster.enable_aad=true&addons.registry=Basic&addons.ingress=none&addons.createAksMetricAlerts=false&addons.azurepolicy=audit&addons.networkPolicy=calico&addons.blobCSIDriver=true&addons.workloadIdentity=true&net.vnet_opt=default&net.aksOutboundTrafficType=loadBalancer&net.afw=false

output aksClusterName {
  value = jsondecode(azurerm_resource_group_template_deployment.aksc_deploy.output_content).aksClusterName.value
  description = "The name of the AKS cluster."
}
output userClientId {
  value = data.azurerm_client_config.current.client_id
  description = "Current User ClientId"
}
output userObjectId {
  value = data.azurerm_client_config.current.object_id
  description = "Current User ObjectId"
}