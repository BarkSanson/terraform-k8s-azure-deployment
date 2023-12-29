provider "azurerm" {
    features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "asi" {
    name     = "asi"
    location = "eastus"
}

resource "azurerm_mysql_flexible_server" "asi_data" {
    name                    = "asi-data"
    resource_group_name     = azurerm_resource_group.asi.name
    location                = azurerm_resource_group.asi.location
    sku_name                = "B_Standard_B1ms"
    administrator_login     = var.adminLogin
    administrator_password  = var.adminPassword
    delegated_subnet_id     = azurerm_subnet.db_subnet.id
}

resource "azurerm_mysql_flexible_database" "asi_db" {
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

    key_vault_secrets_provider {
      secret_rotation_enabled = true
    }

    network_profile {
        network_plugin = "azure"
        network_policy = "azure"
        service_cidr = "172.16.0.0/16"
        dns_service_ip = "172.16.0.10"
    }
}