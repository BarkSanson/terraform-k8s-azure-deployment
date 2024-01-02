provider "azurerm" {
    features {}
}

data "azurerm_client_config" "current" {}


resource "azurerm_resource_group" "asi" {
    name     = "asi2"
    location = "eastus2"
}

module "vpn" {
    source      = "./modules/vpn"
    rg_name     = azurerm_resource_group.asi.name
    location    = azurerm_resource_group.asi.location
}

module "kv" {
    source          = "./modules/key_vault"
    rg_name         = azurerm_resource_group.asi.name
    location        = azurerm_resource_group.asi.location

    tenant_id       = data.azurerm_client_config.current.tenant_id
    object_id       = data.azurerm_client_config.current.object_id

    db_subnet_id    = module.vpn.db_subnet_id
    aks_subnet_id   = module.vpn.aks_subnet_id

    admin_login     = var.admin_login
    admin_password  = var.admin_password
}

module "acr" {
    source   = "./modules/acr"
    rg_name  = azurerm_resource_group.asi.name
    location = azurerm_resource_group.asi.location
}

module "mysql" {
    source          = "./modules/mysql"
    rg_name         = azurerm_resource_group.asi.name
    location        = azurerm_resource_group.asi.location
    db_subnet_id    = module.vpn.db_subnet_id

    admin_login     = var.admin_login
    admin_password  = var.admin_password
}

module "az_storage" {
    source      = "./modules/storage"
    rg_name     = azurerm_resource_group.asi.name
    location    = azurerm_resource_group.asi.location
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
        vnet_subnet_id  = module.vpn.aks_subnet_id
    }

    identity {
        type = "SystemAssigned"
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

    ingress_application_gateway {
        subnet_id = module.vpn.appgw_subnet_id
    }
}

resource "azurerm_role_assignment" "aks-acr-connector" {
    principal_id         = azurerm_kubernetes_cluster.asi.kubelet_identity[0].object_id
    scope                = module.acr.acr_id
    role_definition_name = "AcrPull"
}

//resource "azurerm_role_assignment" "aks-appgw-connector" {
//    principal_id         = module.vpn.vnet_id
//    scope                = azurerm_kubernetes_cluster.asi.ingress_application_gateway[0].subnet_id
//    role_definition_name = "Contributor"
//}