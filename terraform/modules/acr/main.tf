
resource "azurerm_container_registry" "asi_registry" {
    name                = "asiregistry"
    resource_group_name = var.rg_name
    location            = var.location
    sku                 = "Basic"
}