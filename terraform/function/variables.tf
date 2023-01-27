variable "name" {
  description = "name for the function"
}

variable "resource_group_name" {
  description = "resource group name for function"
}

variable "resource_group_location" {
  description = "resource group location for function"
}

variable "app_insights_connection_string" {}

variable "app_insights_instrumentation_key" {}

variable "acr_login_server" {}

variable "acr_id" {}

variable "servicebus_namespace_name" {}

variable "servicebus_topic_id" {}

variable "servicebus_topic_name" {}

variable "servicebus_subscription_name" {}