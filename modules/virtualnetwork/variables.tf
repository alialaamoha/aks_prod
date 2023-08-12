
variable "resource_group_name" {
    type = string
    description = "Name of the resource group conatins vnet"  
}

variable "tags" {
  description = "(Optional) Specifies tags for all the resources"
  default     = {
    createdWith = "Terraform"
  }
}

variable "location" {
  type = string
  description = "location of the resources"
}

variable "vnet_name" {
  type = string
  description = "Virtual network name"
}


variable "address_space" {
  type = list(string)
  description = "CIDR block for the virtual network"
}
variable "subnets" {
    description = "subnets configuration"
    type = list(object({
      name = string
      address_prefixes = list(string)
      private_endpoint_network_policies_enabled = bool
      private_link_service_network_policies_enabled  = bool
    }))
  
}