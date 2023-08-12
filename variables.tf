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

variable "jumbbox_domain_name_label" {
  description = "domain name for the jumbox virtual machine"
  default     = "kubebox"
  type        = string
}

variable "jumbbox_vm_name" {
  description = "Specifies the name of the jumpbox virtual machine"
  default     = "kubeboxVM"
  type        = string
}

variable "jumbbox_vm_public_ip" {
  description = "(Optional) Specifies whether create a public IP for the virtual machine"
  type = bool
  default = false
}

variable "jumbbox_vm_size" {
  description = "Specifies the size of the jumpbox virtual machine"
  default     = "Standard_DS1_v2"
  type        = string
}

variable "jumbbox_vm_os_disk_storage_account_type" {
  description = "Specifies the storage account type of the os disk of the jumpbox virtual machine"
  default     = "Premium_LRS"
  type        = string

  
}

variable "jumbbox_vm_os_disk_image" {
  type        = map(string)
  description = "Specifies the os disk image of the virtual machine"
  default     = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS" 
    version   = "latest"
  }
}


variable "admin_username" {
  description = "(Required) Specifies the admin username of the jumpbox virtual machine and AKS worker nodes."
  type        = string
  default     = "azadmin"
}

variable "ssh_public_key" {
  description = "(Required) Specifies the SSH public key for the jumpbox virtual machine and AKS worker nodes."
  type        = string
  default = ""
}

variable "script_name" {
  description = "(Required) Specifies the name of the custom script."
  type        = string
  default     = "jumbbox.sh"
}

variable "bastion_host_name" {
  description = "(Optional) Specifies the name of the bastion host"
  default     = "devshellBastionHost"
  type        = string
}

variable "storage_account_kind" {
  description = "(Optional) Specifies the account kind of the storage account"
  default     = "StorageV2"
  type        = string

   validation {
    condition = contains(["Storage", "StorageV2"], var.storage_account_kind)
    error_message = "The account kind of the storage account is invalid."
  }
}

variable "storage_account_tier" {
  description = "(Optional) Specifies the account tier of the storage account"
  default     = "Standard"
  type        = string

   validation {
    condition = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "The account tier of the storage account is invalid."
  }
}


variable "storage_account_replication_type" {
  description = "(Optional) Specifies the replication type of the storage account"
  default     = "LRS"
  type        = string

  validation {
    condition = contains(["LRS", "ZRS", "GRS", "GZRS", "RA-GRS", "RA-GZRS"], var.storage_account_replication_type)
    error_message = "The replication type of the storage account is invalid."
  }
}