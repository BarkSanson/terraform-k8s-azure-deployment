resource "azurerm_private_dns_zone" "db_dns" {
    name                = "asi.private.mysql.database.azure.com"
    resource_group_name = var.rg_name

}

resource "azurerm_private_dns_zone_virtual_network_link" "db_dns_link" {
    name                    = "db-link"
    resource_group_name     = var.rg_name
    private_dns_zone_name   = azurerm_private_dns_zone.db_dns.name
    virtual_network_id      = var.db_vnet_id
}

resource "azurerm_private_dns_zone_virtual_network_link" "aks_dns_link" {
    name                    = "aks-link"
    resource_group_name     = var.rg_name
    private_dns_zone_name   = azurerm_private_dns_zone.db_dns.name
    virtual_network_id      = var.aks_vnet_id
}

resource "azurerm_mysql_flexible_server" "asi_db_server" {
    name                    = "asi-db-server"
    resource_group_name     = var.rg_name 
    location                = var.location
    sku_name                = "B_Standard_B1ms"
    administrator_login     = var.admin_login
    administrator_password  = var.admin_password
    delegated_subnet_id     = var.db_subnet_id
    private_dns_zone_id     = azurerm_private_dns_zone.db_dns.id

    depends_on = [ azurerm_private_dns_zone_virtual_network_link.db_dns_link ]
}

resource "azurerm_mysql_flexible_server_configuration" "disable_tls" {
    name = "require_secure_transport"
    resource_group_name = var.rg_name
    server_name = azurerm_mysql_flexible_server.asi_db_server.name
    value = "OFF"
}

resource "azurerm_mysql_flexible_database" "asi_db" {
    name                = "asi-db"
    resource_group_name = var.rg_name
    server_name         = azurerm_mysql_flexible_server.asi_db_server.name
    charset             = "utf8"
    collation           = "utf8_unicode_ci"
}