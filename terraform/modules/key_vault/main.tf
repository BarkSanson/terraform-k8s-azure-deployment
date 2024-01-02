data "http" "ip" {
  url = "https://ipv4.icanhazip.com"
}

resource "azurerm_key_vault" "asi" {
    name                        = "asi-kv2"
    resource_group_name         = var.rg_name
    location                    = var.location
    enabled_for_disk_encryption = true
    tenant_id                   = var.tenant_id

    sku_name = "standard"

    enable_rbac_authorization = true

    access_policy {
      tenant_id = var.tenant_id
      object_id = var.object_id

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
            var.db_subnet_id,
            var.aks_subnet_id
        ]

        ip_rules = [ 
            "${chomp(data.http.ip.response_body)}"
         ]
    }
}