variable "location" {
  description = "location of the region"
  type = string
  default     = "westus"

}

variable "resource_group_name" {
  description = "resource group for vnet"
  default = "aks-rg"
  type        = string
}

variable "tags" {
  description = "(Optional) Specifies tags for all the resources"
  default = {
    createdWith = "Terraform"
  }
}
variable "hub_vnet_name" {
  description = "name of the hub virtual network "
  type        = string
  default     = "hub-vnet"

}

variable "hub_address_space" {
  description = "cidr block for the network cidr"
  type        = list(string)
  default     = ["10.1.0.0/16"]
}

variable "hub_firewall_subnet_address_prefix" {
  description = "address firewall prefix "
  type        = list(string)
  default     = ["10.1.0.0/24"]

}

variable "hub_bastion_subnet_address_prefix" {
  description = "cidr for thhe bastion connection"
  type        = list(string)
  default     = ["10.1.1.0/24"]

}

variable "aks_vnet_name" {
  description = "AKS virtual network"
  type      = string
  default     = "aks-vnet"
}

variable "aks_vnet_address_space" {
  description = "value"
  type =         list(string)
  default     = ["10.0.0.0/16"]

}

variable "aks_pod_subnet_name" {
  description = "Name of the pod subnet."
  default     =  "PodSubnet"
  type        = string
}

variable "aks_pod_subnet_address_prefix" {
  description = "Address prefix of the pod subnet"
  type        = list(string)
  default     = ["10.0.32.0/20"]
}
variable "default_node_pool_name" {
  description = "Specifies the name of the default node pool"
  default     =  "system"
  type        = string
}

variable "default_node_pool_subnet_name" {
  description = "Name of the subnet that hosts the default node pool"
  default     =  "SystemSubnet"
  type        = string
}

variable "default_node_pool_subnet_address_prefix" {
  description = "Address prefix of the subnet that hosts the default node pool"
  default     =  ["10.0.0.0/20"]
  type        = list(string)
}
variable "additional_node_pool_subnet_name" {
  description = "Name of the subnet that hosts the default node pool"
  default     =  "UserSubnet"
  type        = string
}

variable "additional_node_pool_subnet_address_prefix" {
  description = "Address prefix of the subnet that hosts the additional node pool"
  type        = list(string)
  default     = ["10.0.16.0/20"]
}

variable "additional_node_pool_name" {
  description = "(Required) Specifies the name of the node pool."
  type        = string
  default     = "user"
}

variable "network_plugin" {
  description = "Network plugin of the AKS cluster"
  default     = "azure"
  type        = string
}


variable "jumbbox_subnet_name" {
  description = "Jumb box VM subnet name"
  type        = string
  default     = "Jbox-subnet"
}

variable "jumbbox_subnet_address_prefix" {
  description = "Jumb box VM subnet address prefix"
  type        = list(string)
  default     = ["10.0.48.0/20"]
}

