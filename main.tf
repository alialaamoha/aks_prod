provider "azurerm" {
  features {

  }
}

# resource groups

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