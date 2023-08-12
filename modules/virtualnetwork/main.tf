terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
    }
  }
}



resource "azurerm_virtual_network" "vnet" {

 name = var.vnet_name
 resource_group_name =  var.resource_group_name
 location = var.location
 tags = var.tags
 address_space = var.address_space
}


resource "azurerm_subnet" "subnet" {
  for_each = {for subnet in var.subnets: subnet.name => subnet}

  name = each.key
  resource_group_name = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = each.value.address_prefixes

  private_endpoint_network_policies_enabled = each.value.private_endpoint_network_policies_enabled
  private_link_service_network_policies_enabled  = each.value.private_link_service_network_policies_enabled
}