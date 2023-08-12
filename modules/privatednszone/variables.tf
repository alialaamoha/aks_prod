variable "name" {
  description = "(Required) Name of the private dns zone"
  type        = string
}

variable "resource_group_name" {
  description = "(Required) Resource group name of the private dns zone"
  type        = string
}

variable "tags" {
  description = "(Optional) Tags of the private dns zone"
  default     = {}
}

variable "virtual_networks_to_link" {
  description = "(Optional) subscription id, resource group name, and name of the virtual networks to which create a virtual network link"
  type        = map(any)
  default     = {}
}