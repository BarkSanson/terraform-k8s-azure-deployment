provider "azurerm" {
    features {}
}

resource "azurerm_resource_group" "asi" {
    name     = "asi"
    location = "eastus"
}

resource "azurerm_key_vault" "asi" {
    name                        = "asi"
    location                    = azurerm_resource_group.asi.location
    resource_group_name         = azurerm_resource_group.asi.name
    enabled_for_disk_encryption = true
    tenant_id                   = data.azurerm_client_config.current.tenant_id

    sku_name = "standard"

    public_network_access_enabled = false

    access_policy {
        tenant_id = data.azurerm_client_config.current.tenant_id
        object_id = data.azurerm_client_config.current.object_id

        key_permissions = [
            "get",
            "list",
            "create",
            "delete",
            "recover",
            "backup",
            "restore",
            "encrypt",
            "decrypt",
            "unwrapKey",
            "wrapKey"
        ]

        secret_permissions = [
            "get",
            "list",
            "set",
            "delete",
            "recover",
            "backup",
            "restore"
        ]

        storage_permissions = [
            "get",
            "list",
            "delete",
            "set",
            "update",
            "regeneratekey",
            "recover",
            "backup",
            "restore",
            "purge"
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
    delegated_subnet_id     = azurerm_subnet.db_subnet.id
}

resource "azurerm_mysql_flexible_database"  "asi_db" {
    name                = "asi-db"
    resource_group_name = azurerm_resource_group.asi.name
    server_name         = azurerm_mysql_flexible_server.asi_data.name
    charset             = "utf8"
    collation           = "utf8_general_ci"
}

resource "azurerm_kubernetes_cluster" "asi" {
    name                = "asi"
    location            = azurerm_resource_group.asi.location
    resource_group_name = azurerm_resource_group.asi.name
    dns_prefix          = "asi"

    default_node_pool {
        name            = "default"
        node_count      = 1
        vm_size         = "Standard_B2s"
        vnet_subnet_id  = azurerm_subnet.aks_subnet.id
    }

    service_principal {
        client_id     = var.clientId
        client_secret = var.clientSecret
    }

    key_management_service {
        key_vault_key_id = azurerm_key_vault.asi.id
    }
}