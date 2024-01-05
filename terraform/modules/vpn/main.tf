
resource "azurerm_virtual_network" "aks" {
    name                = "aks-vnet"
    resource_group_name = var.rg_name
    location            = var.location
    address_space       = ["10.0.0.0/8"]
}

resource "azurerm_virtual_network" "appgw" {
    name                = "app-gw-vnet"
    resource_group_name = var.rg_name
    location            = var.location
    address_space       = ["192.168.0.0/16"]
}

resource "azurerm_subnet" "db" {
    name                 = "db-subnet"
    resource_group_name  = var.rg_name
    virtual_network_name = azurerm_virtual_network.aks.name
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

resource "azurerm_subnet" "aks" {
    name                 = "aks-subnet"
    resource_group_name  = var.rg_name
    virtual_network_name = azurerm_virtual_network.aks.name
    address_prefixes     = ["10.1.0.0/16"]

    service_endpoints = [ "Microsoft.KeyVault"]
}

resource "azurerm_subnet" "agic" {
    name                 = "agic-subnet"
    resource_group_name  = var.rg_name
    virtual_network_name = azurerm_virtual_network.aks.name
    address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "agic" {
    name                = "agic-nsg"
    location            = var.location
    resource_group_name = var.rg_name

    security_rule {
        name                       = "allow-on-ports-65200-65535"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "65200-65535"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

}

resource "azurerm_subnet_network_security_group_association" "agic" {
    subnet_id                 = azurerm_subnet.agic.id
    network_security_group_id = azurerm_network_security_group.agic.id
}

resource "azurerm_subnet" "appgw_subnet" {
    name = "appgw-subnet"
    resource_group_name = var.rg_name
    virtual_network_name = azurerm_virtual_network.appgw.name
    address_prefixes = ["192.168.0.0/24"] 
}

resource "azurerm_virtual_network_peering" "aks_to_appgw" {
    name = "aks-to-appgw"
    resource_group_name = var.rg_name
    virtual_network_name = azurerm_virtual_network.aks.name
    remote_virtual_network_id = azurerm_virtual_network.appgw.id
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "appgw_to_aks" {
    name = "aks-to-asi"
    resource_group_name = var.rg_name
    virtual_network_name = azurerm_virtual_network.appgw.name
    remote_virtual_network_id = azurerm_virtual_network.aks.id
    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}