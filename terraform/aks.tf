#main.tf 
# Mostly generated from: https://azure.github.io/AKS-Construction/?secure=low&deploy.deployItemKey=deployTf&deploy.rg=remove-this-later&deploy.apiips=&deploy.clusterName=do-not-use&cluster.AksPaidSkuForSLA=false&cluster.agentCount=1&cluster.maxCount=20&cluster.vmSize=Standard_D2s_v3&cluster.osDiskType=Managed&cluster.enable_aad=true&addons.registry=Basic&addons.ingress=none&addons.createAksMetricAlerts=false&addons.azurepolicy=audit&addons.networkPolicy=calico&addons.blobCSIDriver=true&addons.workloadIdentity=true&net.vnet_opt=default&net.aksOutboundTrafficType=loadBalancer&net.afw=false

data "http" "aksc_release" {
  url = "https://github.com/Azure/AKS-Construction/releases/download/0.9.14/main.json"
  request_headers = {
    Accept = "application/json"
    User-Agent = "request module"
  }
}

data "namep_azure_name" "aksc" {
  name     = "m"
  location = "westeurope"
  type     = "azurerm_kubernetes_cluster"
}

resource "azurerm_resource_group_template_deployment" "aksc_deploy" {
  name = "AKS-C"
  resource_group_name = azurerm_resource_group.rg.name
  deployment_mode = "Incremental"
  template_content = data.http.aksc_release.response_body
  parameters_content = jsonencode({
    resourceName = {value=data.namep_azure_name.aksc.result}
    agentCount = {value=var.agentCount}
    upgradeChannel = {value=var.upgradeChannel}
    agentVMSize = {value=var.agentVMSize}
    agentCountMax = {value=var.agentCountMax}
    osDiskType = {value=var.osDiskType}
    enable_aad = {value=var.enable_aad}
    enableAzureRBAC = {value=var.enableAzureRBAC}
    adminPrincipalId = {value=data.azurerm_client_config.current.object_id}
    registries_sku = {value=var.registries_sku}
    acrPushRolePrincipalId = {value=data.azurerm_client_config.current.object_id}
    omsagent = {value=var.omsagent}
    retentionInDays = {value=var.retentionInDays}
    createAksMetricAlerts = {value=var.createAksMetricAlerts}
    networkPolicy = {value=var.networkPolicy}
    azurepolicy = {value=var.azurepolicy}
    blobCSIDriver = {value=var.blobCSIDriver}
    oidcIssuer = {value=var.oidcIssuer}
    workloadIdentity = {value=var.workloadIdentity}
  })
}