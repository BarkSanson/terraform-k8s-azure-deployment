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

    db_vnet_id      = module.vpn.db_vnet_id
    db_subnet_id    = module.vpn.db_subnet_id
    aks_vnet_id     = module.vpn.backend_vnet_id

    admin_login     = var.admin_login
    admin_password  = var.admin_password
}

module "gateway" {
    source      = "./modules/gateway"
    rg_name     = azurerm_resource_group.asi.name
    location    = azurerm_resource_group.asi.location
    subnet_id   = module.vpn.frontend_subnet_id
}

module "aks" {
    source              = "./modules/aks"
    rg_name             = azurerm_resource_group.asi.name
    rg_id               = azurerm_resource_group.asi.id
    location            = azurerm_resource_group.asi.location
    aks_subnet_id       = module.vpn.aks_subnet_id
    acr_id              = module.acr.acr_id
    key_vault_id        = module.kv.keyvault_id
    appgw_identity_id   = module.gateway.appgw_identity_id
    appgw_id            = module.gateway.appgw_id
    appgw_subnet_id     = module.vpn.frontend_subnet_id
}

