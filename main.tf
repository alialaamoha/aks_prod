provider "azurerm" {
  features {

  }
  
}
provider "azuread" {
  
}

data "azurerm_client_config" "current" {
}

data "azuread_client_config" "current" {}

locals {
  storage_account_prefix = "store"
  route_table_name       = "DefaultRouteTable"
  route_name             = "RouteToAzureFirewall"
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

module "kube_network" {
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
    name = var.additional_node_pool_subnet_name
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
  vnet_2_id = module.kube_network.vnet_id

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
  script_path =   var.script_path
  subnet_id = module.kube_network.subnet_ids[var.jumbbox_subnet_name]
}

# key valut 
module "key_vault" {
  source = "./modules/key_vault"
  name = var.key_vault_name
  location = var.location
  resource_group_name = azurerm_resource_group.aks-rg.name
  tenant_id = data.azurerm_client_config.current.tenant_id
  sku_name = var.key_vault_sku_name
  tags = var.tags
  enabled_for_deployment = var.key_vault_enabled_for_deployment
  enabled_for_disk_encryption = var.key_vault_enabled_for_disk_encryption
  enabled_for_template_deployment = var.key_vault_enabled_for_template_deployment
  enable_rbac_authorization = var.key_vault_enable_rbac_authorization
  purge_protection_enabled = var.key_vault_purge_protection_enabled
  soft_delete_retention_days = var.key_vault_soft_delete_retention_days
  bypass = var.key_vault_bypass
  default_action = var.key_vault_default_action 
}

module "key_vault_private_dns_zone" {
  source = "./modules/privatednszone"
  name = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.aks-rg.name
  virtual_networks_to_link = {
   (module.hub_network.name) = { 
      subscription_id  = data.azurerm_client_config.current.subscription_id
      resource_group_name = azurerm_resource_group.aks-rg.name
    }
     (module.kube_network.name) = { 
      subscription_id  = data.azurerm_client_config.current.subscription_id
      resource_group_name = azurerm_resource_group.aks-rg.name
    }
  }
}

module "key_valut_private_endpoint" {
  source = "./modules/private_end_point"
  name = "${title(module.key_vault.name)}-PrivateEndpoint"
  location = var.location
  resource_group_name = azurerm_resource_group.aks-rg.name
  subnet_id = module.kube_network.subnet_ids[var.jumbbox_subnet_name]
  tags = var.tags
  private_connection_resource_id = module.key_vault.id
  is_manual_connection = false
  subresource_name = "vault"
  private_dns_zone_group_name = "KeyVaultPrivateDnsZoneGroup"
  private_dns_zone_group_ids = [module.key_vault_private_dns_zone.id]
}

# container registry
module "acr_private_registry" {
  source = "./modules/container_registry"
  name = var.acr_name
  resource_group_name = azurerm_resource_group.aks-rg.name
  location =  var.location
  sku = var.acr_sku
  georeplication_locations = var.acr_georeplication_locations
  admin_enabled = var.acr_admin_enabled
}

module "acr_private_dns_zone" {
  source = "./modules/privatednszone"
  name = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.aks-rg.name
  virtual_networks_to_link = {
    (module.hub_network.name) = { 
      subscription_id  = data.azurerm_client_config.current.subscription_id
      resource_group_name = azurerm_resource_group.aks-rg.name
    }
     (module.kube_network.name) = { 
      subscription_id  = data.azurerm_client_config.current.subscription_id
      resource_group_name = azurerm_resource_group.aks-rg.name
    }
  }
}

module "acr_private_endpoint" {
  source = "./modules/private_end_point"
  name = "${module.acr_private_registry.name}-PrivateEndpoint"
  location = var.location
  resource_group_name = azurerm_resource_group.aks-rg.name
  subnet_id = module.kube_network.subnet_ids[var.jumbbox_subnet_name]
  tags =  var.tags
  private_connection_resource_id = module.acr_private_registry.id
  is_manual_connection = false
  subresource_name = "registry"
  private_dns_zone_group_name = "AcrPrivateDnsZoneGroup"
  private_dns_zone_group_ids = [module.acr_private_dns_zone.id]
}
# firewall and route table
module "firewall" {
  source = "./modules/azurefirewall"
  name = var.firewall_name
  pip_name = "${var.firewall_name}-PublicIP"
  resource_group_name = azurerm_resource_group.aks-rg.name
  location = var.location
  zones = var.firewall_zones
  sku_name = var.firewall_sku_name
  sku_tier = var.firewall_sku_tier
  tags =  var.tags
  subnet_id = module.hub_network.subnet_ids["AzureFirewallSubnet"]
  threat_intel_mode = var.firewall_threat_intel_mode
}


module "routetable" {
  source = "./modules/routetable"
  resource_group_name = azurerm_resource_group.aks-rg.name
  location = var.location
  route_name = local.route_name
  route_table_name = local.route_table_name
  firewall_private_ip = module.firewall.private_ip_address
  subnets_to_associate = {
    (var.default_node_pool_subnet_name) = {
     subscription_id = data.azurerm_client_config.current.subscription_id
     resource_group_name = azurerm_resource_group.aks-rg.name
     virtual_network_name = module.kube_network.name
    }
    (var.additional_node_pool_subnet_name) = {
      subscription_id = data.azurerm_client_config.current.subscription_id
     resource_group_name = azurerm_resource_group.aks-rg.name
     virtual_network_name = module.kube_network.name
    }
  }
}


module "kube_admin_group" {
  source = "./modules/aad"
  group_name = var.kube_admin
}

# aks
module "aks_cluster" {
  source                                   = "./modules/aks_cluster"
  name                                     = var.aks_cluster_name
  location                                 = var.location
  resource_group_name                      = azurerm_resource_group.aks-rg.name
  resource_group_id                        = azurerm_resource_group.aks-rg.id
  kubernetes_version                       = module.aks_cluster.latest_version
  dns_prefix                               = lower(var.aks_cluster_name)
  private_cluster_enabled                  = true
  automatic_channel_upgrade                = var.automatic_channel_upgrade
  sku_tier                                 = var.sku_tier
  default_node_pool_name                   = var.default_node_pool_name
  default_node_pool_vm_size                = var.default_node_pool_vm_size
  vnet_subnet_id                           = module.kube_network.subnet_ids[var.default_node_pool_subnet_name]
  default_node_pool_availability_zones     = var.default_node_pool_availability_zones
  default_node_pool_node_labels            = var.default_node_pool_node_labels
  default_node_pool_node_taints            = var.default_node_pool_node_taints
  default_node_pool_enable_auto_scaling    = var.default_node_pool_enable_auto_scaling
  default_node_pool_enable_host_encryption = var.default_node_pool_enable_host_encryption
  default_node_pool_enable_node_public_ip  = var.default_node_pool_enable_node_public_ip
  default_node_pool_max_pods               = var.default_node_pool_max_pods
  default_node_pool_max_count              = var.default_node_pool_max_count
  default_node_pool_min_count              = var.default_node_pool_min_count
  default_node_pool_node_count             = var.default_node_pool_node_count
  default_node_pool_os_disk_type           = var.default_node_pool_os_disk_type
  tags                                     = var.tags
  network_dns_service_ip                   = var.network_dns_service_ip
  network_plugin                           = var.network_plugin
  outbound_type                            = "userDefinedRouting"
  network_service_cidr                     = var.network_service_cidr
  role_based_access_control_enabled        = var.role_based_access_control_enabled
  tenant_id                                = data.azurerm_client_config.current.tenant_id
  admin_group_object_ids                   = [module.kube_admin_group.object_id]
  azure_rbac_enabled                       = var.azure_rbac_enabled
  admin_username                           = var.admin_username
  ssh_public_key                           = module.ssh_key.ssh_public_key
  workload_identity_enabled                = var.workload_identity_enabled
  oidc_issuer_enabled =                    var.oidc_issuer_enabled
  azure_policy_enabled                     = var.azure_policy_enabled
  http_application_routing_enabled         = var.http_application_routing_enabled


  depends_on = [ module.routetable , module.kube_admin_group]
}

resource "azurerm_role_assignment" "network_contributor" {
  scope                = azurerm_resource_group.aks-rg.id
  role_definition_name = "Network Contributor"
  principal_id         = module.aks_cluster.aks_identity_principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "acr_pull" {
  role_definition_name = "AcrPull"
  scope                = module.acr_private_registry.id
  principal_id         = module.aks_cluster.kubelet_identity_object_id
  skip_service_principal_aad_check = true
}

module "blob_private_dns_zone" {
  source                       = "./modules/privatednszone"
  name                         = "privatelink.blob.core.windows.net"
  resource_group_name          = azurerm_resource_group.aks-rg.name
  virtual_networks_to_link     = {
    (module.hub_network.name) = {
      subscription_id = data.azurerm_client_config.current.subscription_id
      resource_group_name = azurerm_resource_group.aks-rg.name
    }
    (module.kube_network.name) = {
      subscription_id = data.azurerm_client_config.current.subscription_id
      resource_group_name = azurerm_resource_group.aks-rg.name
    }
  }
}


module "blob_private_endpoint" {
  source                         = "./modules/private_end_point"
  name                           = "${title(module.storage_account.name)}-PrivateEndpoint"
  location                       = var.location
  resource_group_name            = azurerm_resource_group.aks-rg.name
  subnet_id                      = module.kube_network.subnet_ids[var.jumbbox_subnet_name]
  tags                           = var.tags
  private_connection_resource_id = module.storage_account.id
  is_manual_connection           = false
  subresource_name               = "blob"
  private_dns_zone_group_name    = "BlobPrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.blob_private_dns_zone.id]
}