variable "branch" {
  description = "optional branch for use in the name"
  default = ""
}

#variables.tf - https://azure.github.io/AKS-Construction/?secure=low&deploy.deployItemKey=deployTf&deploy.rg=remove-this-later&deploy.apiips=&deploy.clusterName=do-not-use&cluster.AksPaidSkuForSLA=false&cluster.agentCount=1&cluster.maxCount=20&cluster.vmSize=Standard_D2s_v3&cluster.osDiskType=Managed&cluster.enable_aad=true&addons.registry=Basic&addons.ingress=none&addons.createAksMetricAlerts=false&addons.azurepolicy=audit&addons.networkPolicy=calico&addons.blobCSIDriver=true&addons.workloadIdentity=true&net.vnet_opt=default&net.aksOutboundTrafficType=loadBalancer&net.afw=false

variable location {
  type=string
  default="WestEurope"
} 
variable agentCount {
  type=number
  default=1
} 
variable upgradeChannel {
  type=string
  default="stable"
} 
variable agentVMSize {
  type=string
  default="Standard_D2s_v3"
} 
variable agentCountMax {
  type=number
  default=20
} 
variable osDiskType {
  type=string
  default="Managed"
} 
variable enable_aad {
  type=bool
  default=true
} 
variable enableAzureRBAC {
  type=bool
  default=true
} 
variable registries_sku {
  type=string
  default="Basic"
} 
variable omsagent {
  type=bool
  default=true
} 
variable retentionInDays {
  type=number
  default=30
} 
variable createAksMetricAlerts {
  type=bool
  default=false
} 
variable networkPolicy {
  type=string
  default="calico"
} 
variable azurepolicy {
  type=string
  default="audit"
} 
variable blobCSIDriver {
  type=bool
  default=true
} 
variable oidcIssuer {
  type=bool
  default=true
} 
variable workloadIdentity {
  type=bool
  default=true
}