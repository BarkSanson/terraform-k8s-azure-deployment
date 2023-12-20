provider "azurerm" {
    features {}
}

resource "azurerm_resource_group" "asi" {
    name     = "asi"
    location = "eastus"
}

data "azuread_client_config" "current" {}

resource "azurerm_key_vault" "asi_vault" {
    name = "asi-vault"
    resource_group_name = azurerm_resource_group.asi.name
    location = azurerm_resource_group.asi.location
    tenant_id = data.azuread_client_config.current.tenant_id

    sku_name = "standard"

    network_acls {
        default_action = "Deny"
        bypass = "AzureServices"
    }

    access_policy {
        tenant_id = data.azuread_client_config.current.tenant_id
        object_id = data.azuread_client_config.current.object_id

        key_permissions = [ 
            "Get",
            "List",
            "Sign"
        ]

        secret_permissions = [
            "Get",
            "List",
            "Set"
        ] 
        
        storage_permissions = [
            "Get",
            "List",
            "RegenerateKey",
            "Set",
            "Update"
        ]
    }
}

resource "azurerm_mysql_flexible_server" "asi_data" {
    name                    = "asi-data"
    resource_group_name     = azurerm_resource_group.asi.name
    location                = azurerm_resource_group.asi.location
    sku_name                = "B_Standard_B1s"
    administrator_login     = var.adminLogin
    administrator_password  = var.adminPassword
    delegated_subnet_id     = azurerm_subnet.asi_subnet.id
}

resource "azurerm_mysql_flexible_database"  "asi_db" {
    name                = "asi-db"
    resource_group_name = azurerm_resource_group.asi.name
    server_name         = azurerm_mysql_flexible_server.asi_data.name
    charset             = "utf8"
    collation           = "utf8_general_ci"
}