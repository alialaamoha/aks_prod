
data "azuread_client_config" "current" {}

resource "azuread_group" "azgroup" {
  display_name     = var.group_name
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true
}