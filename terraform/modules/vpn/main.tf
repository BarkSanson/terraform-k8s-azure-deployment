
resource "azurerm_virtual_network" "asi_vnet" {
    name                = "asi-vnet2"
    resource_group_name = var.rg_name
    location            = var.location
    address_space       = ["10.0.0.0/8"]
}

resource "azurerm_subnet" "db_subnet" {
    name                 = "db-subnet"
    resource_group_name  = var.rg_name
    virtual_network_name = azurerm_virtual_network.asi_vnet.name
    address_prefixes     = ["10.0.1.0/24"]
    service_endpoints = [ "Microsoft.KeyVault" ]
    delegation {
        name = "asi-delegation"
        service_delegation {
            name    = "Microsoft.DBforMySQL/flexibleServers"
            actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
    }
}

resource "azurerm_subnet" "aks_subnet" {
    name                 = "aks-subnet"
    resource_group_name  = var.rg_name
    virtual_network_name = azurerm_virtual_network.asi_vnet.name
    address_prefixes     = ["10.1.0.0/16"]

    service_endpoints = [ "Microsoft.KeyVault"]
}

resource "azurerm_subnet" "appgw_subnet" {
    name = "appgw-subnet"
    resource_group_name = var.rg_name
    virtual_network_name = azurerm_virtual_network.asi_vnet.name
    address_prefixes = ["10.2.0.0/24"] 
}
