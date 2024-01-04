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

module "appgw" {
    source      = "./modules/appgw"
    rg_name     = azurerm_resource_group.asi.name
    location    = azurerm_resource_group.asi.location
    subnet_id   = module.vpn.appgw_subnet_id
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
        gateway_id = module.appgw.appgw_id
    }
}

resource "azurerm_role_assignment" "aks-acr-connector" {
    principal_id         = azurerm_kubernetes_cluster.asi.kubelet_identity[0].object_id
    scope                = module.acr.acr_id
    role_definition_name = "AcrPull"
}

data "azurerm_user_assigned_identity" "aks_ingress_appgw" {
    name                = "ingressapplicationgateway-${azurerm_kubernetes_cluster.asi.name}"
    resource_group_name = azurerm_kubernetes_cluster.asi.node_resource_group
}

resource "azurerm_role_assignment" "aks_appgw_connector" {
    principal_id         = data.azurerm_user_assigned_identity.aks_ingress_appgw.principal_id
    scope                = module.appgw.appgw_id
    role_definition_name = "Contributor"
}

resource "azurerm_role_assignment" "aks_appgw_rg_reader" {
    principal_id         = data.azurerm_user_assigned_identity.aks_ingress_appgw.principal_id
    scope                = azurerm_resource_group.asi.id
    role_definition_name = "Reader"
}

resource "azurerm_role_assignment" "aks_appgw_identity_contributor" {
    principal_id         = data.azurerm_user_assigned_identity.aks_ingress_appgw.principal_id
    scope                = module.appgw.appgw_assigned_identity
    role_definition_name = "Contributor"
}

resource "azurerm_role_assignment" "aks_vpn_contributor" {
    principal_id         = data.azurerm_user_assigned_identity.aks_ingress_appgw.principal_id
    scope                = module.vpn.appgw_vnet_id
    role_definition_name = "Network Contributor"
}


data "azurerm_user_assigned_identity" "aks_kv" {
    name = "azurekeyvaultsecretsprovider-${azurerm_kubernetes_cluster.asi.name}"
    resource_group_name = azurerm_kubernetes_cluster.asi.node_resource_group
}

resource "azurerm_role_assignment" "aks-kv-connector" {
    principal_id         = data.azurerm_user_assigned_identity.aks_kv.principal_id
    scope                = module.kv.keyvault_id
    role_definition_name = "Key Vault Administrator"
}
