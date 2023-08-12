resource "azuread_group" "groups" {
  name        = "${var.group_name}"
  description = "Azure AKS Kubernetes administrators for the ${var.group_name}."
}