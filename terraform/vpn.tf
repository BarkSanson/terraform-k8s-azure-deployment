data "azurerm_resource_group" "asi" {
    name     = "asi"
}

resource "azurerm_virtual_network" "asi_vnet" {
    name                = "asi-vnet"
    resource_group_name = azurerm_resource_group.asi.name
    location            = azurerm_resource_group.asi.location
    address_space       = ["10.0.0.0/8"]
}

resource "azurerm_subnet" "db_subnet" {
    name                 = "db-subnet"
    resource_group_name  = azurerm_resource_group.asi.name
    virtual_network_name = azurerm_virtual_network.asi_vnet.name
    address_prefixes     = ["10.0.0.0/24"]
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
    resource_group_name  = azurerm_resource_group.asi.name
    virtual_network_name = azurerm_virtual_network.asi_vnet.name
    address_prefixes     = ["10.1.0.0/16"]

    delegation {
        name = "asi-delegation"
        service_delegation {
            name    = "Microsoft.ContainerInstance/containerGroups"
            actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
    }
}