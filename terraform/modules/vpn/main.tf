
resource "azurerm_virtual_network" "aks" {
    name                = "aks-vnet"
    resource_group_name = var.rg_name
    location            = var.location
    // AKS requires at least 500 something IP addresses, so
    // you know, just give it a bunch of IPs. Better to have it and 
    // not need it than to need it and not have it ¯\_(ツ)_/¯
    address_space       = ["10.0.0.0/8"]
}

resource "azurerm_virtual_network" "appgw" {
    name                = "app-gw-vnet"
    resource_group_name = var.rg_name
    location            = var.location
    address_space       = ["192.168.0.0/16"]
}

resource "azurerm_virtual_network" "db" {
    name                = "db-vnet"
    resource_group_name = var.rg_name
    location            = var.location
    address_space       = ["192.169.0.0/16"]
}

resource "azurerm_subnet" "db" {
    name                 = "db-subnet"
    resource_group_name  = var.rg_name
    virtual_network_name = azurerm_virtual_network.db.name
    address_prefixes     = ["192.169.0.0/24"]
    delegation {
        name = "asi-delegation"
        service_delegation {
            name    = "Microsoft.DBforMySQL/flexibleServers"
            actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
    }
}
resource "azurerm_subnet" "aks" {
    name                 = "aks-subnet"
    resource_group_name  = var.rg_name
    virtual_network_name = azurerm_virtual_network.aks.name
    address_prefixes     = ["10.1.0.0/16"]

    service_endpoints    = [ "Microsoft.KeyVault"]
}

resource "azurerm_subnet" "appgw_subnet" {
    name                    = "appgw-subnet"
    resource_group_name     = var.rg_name
    virtual_network_name    = azurerm_virtual_network.appgw.name
    address_prefixes        = ["192.168.0.0/24"] 
}

resource "azurerm_virtual_network_peering" "aks_to_appgw" {
    name                            = "aks-to-appgw"
    resource_group_name             = var.rg_name
    virtual_network_name            = azurerm_virtual_network.aks.name
    remote_virtual_network_id       = azurerm_virtual_network.appgw.id
    allow_virtual_network_access    = true
    allow_forwarded_traffic         = true
}

resource "azurerm_virtual_network_peering" "appgw_to_aks" {
    name                            = "aks-to-asi"
    resource_group_name             = var.rg_name
    virtual_network_name            = azurerm_virtual_network.appgw.name
    remote_virtual_network_id       = azurerm_virtual_network.aks.id
    allow_virtual_network_access    = true
    allow_forwarded_traffic         = true
}

resource "azurerm_virtual_network_peering" "aks_to_db" {
    name                            = "aks-to-db"
    resource_group_name             = var.rg_name
    virtual_network_name            = azurerm_virtual_network.aks.name
    remote_virtual_network_id       = azurerm_virtual_network.db.id
    allow_virtual_network_access    = true
    allow_forwarded_traffic         = true
}

resource "azurerm_virtual_network_peering" "db_to_aks" {
    name                            = "db-to-aks"
    resource_group_name             = var.rg_name
    virtual_network_name            = azurerm_virtual_network.db.name
    remote_virtual_network_id       = azurerm_virtual_network.aks.id
    allow_virtual_network_access    = true
    allow_forwarded_traffic         = true
}