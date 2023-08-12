provider "azurerm" {
  features {

  }
}

data "azurerm_client_config" "current" {
}

locals {
  storage_account_prefix = "store"
}

# reasource group for AKS Cluster 
resource "azurerm_resource_group" "aks-rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# resource group for VNet - Hub 
module "hub_network" {
  source              = "./modules/virtualnetwork"
  resource_group_name = azurerm_resource_group.aks-rg.name
  location            = var.location
  vnet_name           = var.hub_vnet_name
  address_space       = var.hub_address_space
  tags                = var.tags
  subnets = [{
    name                                           = "AzureFirewallSubnet"
    address_prefixes                               = var.hub_firewall_subnet_address_prefix
    private_endpoint_network_policies_enabled = true
    private_link_service_network_policies_enabled = false
    }, {
    name                                           = "AzureBastionSubnet"
    address_prefixes                               = var.hub_bastion_subnet_address_prefix
    private_endpoint_network_policies_enabled = true
    private_link_service_network_policies_enabled = false
  }]
}

module "aks_network" {
  source = "./modules/virtualnetwork"
  resource_group_name = azurerm_resource_group.aks-rg.name
  location = var.location
  vnet_name = var.aks_vnet_name
  address_space = var.aks_vnet_address_space
  tags = var.tags

  subnets = [ {
    name = var.default_node_pool_subnet_name
    address_prefixes = var.default_node_pool_subnet_address_prefix
    private_endpoint_network_policies_enabled = true
    private_link_service_network_policies_enabled = false
  },
  {
    name = var.aks_pod_subnet_name
    address_prefixes = var.aks_pod_subnet_address_prefix
    private_endpoint_network_policies_enabled = true
    private_link_service_network_policies_enabled = false

  },{
    name = var.additional_node_pool_name
    address_prefixes = var.additional_node_pool_subnet_address_prefix
    private_endpoint_network_policies_enabled = true
    private_link_service_network_policies_enabled = false
  },{
    name = var.jumbbox_subnet_name
    address_prefixes = var.jumbbox_subnet_address_prefix
    private_endpoint_network_policies_enabled = true
    private_link_service_network_policies_enabled = false
  }
  
   ]
}


module "vnet_peering" {
  source = "./modules/virtualpeering"

  vnet_1_name = var.hub_vnet_name
  vnet_1_rg = azurerm_resource_group.aks-rg.name
  vnet_1_id = module.hub_network.vnet_id

  vnet_2_name = var.aks_vnet_name
  vnet_2_rg = azurerm_resource_group.aks-rg.name
  vnet_2_id = module.aks_network.vnet_id

  peering_name_1_to_2 = "${var.hub_vnet_name}To${var.aks_vnet_name}"
  peering_name_2_to_1 = "${var.aks_vnet_name}To${var.hub_vnet_name}"
}

module "bastion_host" {
  source = "./modules/bastion_host"
  name = var.bastion_host_name
  location = var.location
  resource_group_name = azurerm_resource_group.aks-rg.name
  subnet_id = module.hub_network.subnet_ids["AzureBastionSubnet"]
  tags = var.tags
  
}

# Generate randon name for virtual machine
resource "random_string" "storage_account_suffix" {
  length  = 8
  special = false
  lower   = true
  upper   = false
  numeric  = false
}

module "storage_account" {
  source = "./modules/storage_account"
  name = "${local.storage_account_prefix}${random_string.storage_account_suffix.result}"
  location = var.location
  resource_group_name = azurerm_resource_group.aks-rg.name
  account_kind = var.storage_account_kind
  account_tier = var.storage_account_tier
  replication_type = var.storage_account_replication_type
  
}

module "ssh_key" {
  source = "./modules/ssh"
}

module "jumbbox_kube" {
  source = "./modules/virtualmachine"
  resource_group_name = azurerm_resource_group.aks-rg.name
  name = var.jumbbox_vm_name
  size = var.jumbbox_vm_size
  location = var.location
  public_ip = var.jumbbox_vm_public_ip
  vm_user = var.admin_username
  admin_ssh_public_key = module.ssh_key.ssh_public_key
  os_disk_image = var.jumbbox_vm_os_disk_image
  domain_name_label = var.jumbbox_domain_name_label
  script_name = var.script_name
  subnet_id = module.aks_network.subnet_ids[var.jumbbox_subnet_name]
}

