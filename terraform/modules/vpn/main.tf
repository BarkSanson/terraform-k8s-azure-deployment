
resource "azurerm_virtual_network" "backend" {
    name                = "backend-vnet"
    resource_group_name = var.rg_name
    location            = var.location
    // AKS requires at least 500 something IP addresses, so
    // you know, just give it a bunch of IPs. Better to have it and 
    // not need it than to need it and not have it ¯\_(ツ)_/¯
    address_space       = ["10.0.0.0/8"]
}

resource "azurerm_virtual_network" "frontend" {
    name                = "frontend-vnet"
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
    virtual_network_name = azurerm_virtual_network.backend.name
    address_prefixes     = ["10.1.0.0/16"]

    service_endpoints    = [ "Microsoft.KeyVault"]
}

resource "azurerm_subnet" "frontend" {
    name                    = "frontend-subnet"
    resource_group_name     = var.rg_name
    virtual_network_name    = azurerm_virtual_network.frontend.name
    address_prefixes        = ["192.168.0.0/24"] 
}

resource "azurerm_virtual_network_peering" "backend_to_frontend" {
    name                            = "backend-to-frontend"
    resource_group_name             = var.rg_name
    virtual_network_name            = azurerm_virtual_network.backend.name
    remote_virtual_network_id       = azurerm_virtual_network.frontend.id
    allow_virtual_network_access    = true
    allow_forwarded_traffic         = true
}

resource "azurerm_virtual_network_peering" "frontend_to_backend" {
    name                            = "frontend-to-backend"
    resource_group_name             = var.rg_name
    virtual_network_name            = azurerm_virtual_network.frontend.name
    remote_virtual_network_id       = azurerm_virtual_network.backend.id
    allow_virtual_network_access    = true
    allow_forwarded_traffic         = true
}

resource "azurerm_virtual_network_peering" "backend_to_db" {
    name                            = "backend-to-db"
    resource_group_name             = var.rg_name
    virtual_network_name            = azurerm_virtual_network.backend.name
    remote_virtual_network_id       = azurerm_virtual_network.db.id
    allow_virtual_network_access    = true
    allow_forwarded_traffic         = true
}

resource "azurerm_virtual_network_peering" "db_to_backend" {
    name                            = "db-to-backend"
    resource_group_name             = var.rg_name
    virtual_network_name            = azurerm_virtual_network.db.name
    remote_virtual_network_id       = azurerm_virtual_network.backend.id
    allow_virtual_network_access    = true
    allow_forwarded_traffic         = true
}