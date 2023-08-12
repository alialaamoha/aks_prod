
output "name" {
  description = "name of the created virtual network"
  value = azurerm_virtual_network.vnet.name
}

output "vnet_id" {
  description = "ID of the created virtual network"
  value = azurerm_virtual_network.vnet.id
}

output "subnet_ids" {
 description = "contains list of the subnets ids"
 value = {for subnet in azurerm_subnet.subnet : subnet.name => subnet.id }
  
}