data "http" "ip" {
  url = "https://ipv4.icanhazip.com"
}

resource "azurerm_key_vault" "asi" {
    name                        = "asi"
    location                    = azurerm_resource_group.asi.location
    resource_group_name         = azurerm_resource_group.asi.name
    enabled_for_disk_encryption = true
    tenant_id                   = data.azurerm_client_config.current.tenant_id

    sku_name = "standard"

    public_network_access_enabled = true

    access_policy {
        tenant_id = data.azurerm_client_config.current.tenant_id
        object_id = data.azurerm_client_config.current.object_id

        key_permissions = []

        secret_permissions = [
            "Get",
            "List",
            "Set",
            "Delete",
            "Recover",
            "Backup",
            "Restore",
            "Purge"
        ]

        storage_permissions = []
    }

    network_acls {
        default_action = "Deny"

        bypass = "AzureServices"

        virtual_network_subnet_ids = [ 
            azurerm_subnet.db_subnet.id,
            azurerm_subnet.aks_subnet.id
        ]

        ip_rules = [ 
            "${chomp(data.http.ip.response_body)}"
         ]
    }
}

resource "azurerm_key_vault_secret" "db_user" {
  name         = "ASI-DB-USER"
  value        = var.adminLogin 
  key_vault_id = azurerm_key_vault.asi.id
}

resource "azurerm_key_vault_secret" "db_pass" {
  name         = "ASI-DB-PASS"
  value        = var.adminPassword
  key_vault_id = azurerm_key_vault.asi.id 
}