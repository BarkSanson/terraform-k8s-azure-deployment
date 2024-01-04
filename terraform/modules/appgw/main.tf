resource "azurerm_public_ip" "app_gw" {
    name = "asi"
    resource_group_name = var.rg_name
    location = var.location
    allocation_method = "Static"
    sku = "Standard"
    domain_name_label = "asi"
}

locals {
    backend_address_pool_name       = "asi-gw-pool"
    frontend_port_name              = "asi-gw-port"
    frontend_ip_configuration_name  = "asi-gw-ip"
    http_setting_name               = "asi-gw-settings"
    http_listener_name              = "asi-gw-listener"
    request_routing_rule_name       = "asi-gw-rule"
}

resource "azurerm_user_assigned_identity" "asi_gw" {
    name = "asi-gw"
    resource_group_name = var.rg_name
    location = var.location
}

resource "azurerm_application_gateway" "asi_gw" {

    name = "asi-gw"
    resource_group_name = var.rg_name
    location = var.location

    sku {
        name = "Standard_v2"
        tier = "Standard_v2"
        capacity = 2
    }

    gateway_ip_configuration {
        name = "asi-ip-config"
        subnet_id = var.subnet_id
    }

    frontend_port {
        name = local.frontend_port_name
        port = 80
    }

    frontend_ip_configuration {
        name = local.frontend_ip_configuration_name
        public_ip_address_id = azurerm_public_ip.app_gw.id
    }

    backend_address_pool {
        name = local.backend_address_pool_name
    }

    backend_http_settings {
        name = local.http_setting_name
        cookie_based_affinity = "Disabled"
        port = 80
        protocol = "Http"
        request_timeout = 60
    }

    http_listener {
        name = local.http_listener_name
        frontend_ip_configuration_name = "asi-gw-ip"
        frontend_port_name = "asi-gw-port"
        protocol = "Http"
    }

    request_routing_rule {
        priority = 5
        name = local.request_routing_rule_name
        rule_type = "Basic"
        http_listener_name = local.http_listener_name
        backend_address_pool_name = local.backend_address_pool_name
        backend_http_settings_name = local.http_setting_name
    }

    identity {
        type = "UserAssigned"
        identity_ids = [azurerm_user_assigned_identity.asi_gw.id]
    }

}