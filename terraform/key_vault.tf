
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
        application_id = var.clientId

        key_permissions = [
            "Get",
            "List",
            "Update",
            "Create",
            "Import",
            "Delete",
            "Recover",
            "Backup",
            "Restore"
        ]

        secret_permissions = [
            "Get",
            "List",
            "Set",
            "Delete",
            "Recover",
            "Backup",
            "Restore"
        ]

        storage_permissions = [
            "Get",
            "List",
            "Delete",
            "Set",
            "Update",
            "RegenerateKey",
            "Recover",
            "Backup",
            "Restore",
        ]
    }

    network_acls {
        default_action = "Deny"

        bypass = "AzureServices"

        virtual_network_subnet_ids = [ 
            azurerm_subnet.db_subnet.id,
            azurerm_subnet.aks_subnet.id
        ]
    }
}