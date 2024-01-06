locals {
    backend_address_pool_name       = "frontend-pool"
    frontend_port_name              = "frontend-port"
    frontend_ip_configuration_name  = "frontend-ip"
    http_setting_name               = "frontend-settings"
    http_listener_name              = "frontend-listener"
    request_routing_rule_name       = "frontend-rule"
}

resource "azurerm_user_assigned_identity" "frontend" {
    name = "frontend"
    resource_group_name = var.rg_name
    location = var.location
}

resource "azurerm_public_ip" "frontend" {
    name = "frontend"
    resource_group_name = var.rg_name
    location = var.location
    allocation_method = "Static"
    sku = "Standard"
    domain_name_label = "asi"
}

resource "azurerm_application_gateway" "frontend" {
    name = "frontend"
    resource_group_name = var.rg_name
    location = var.location

    sku {
        name = "Standard_v2"
        tier = "Standard_v2"
        capacity = 2
    }

    gateway_ip_configuration {
        name = "frontend-ip-config"
        subnet_id = var.subnet_id
    }

    frontend_port {
        name = local.frontend_port_name
        port = 80
    }

    frontend_ip_configuration {
        name = local.frontend_ip_configuration_name
        public_ip_address_id = azurerm_public_ip.frontend.id
    }

    backend_address_pool {
        name = local.backend_address_pool_name
    }

    backend_http_settings {
        name                    = local.http_setting_name
        cookie_based_affinity   = "Disabled"
        port                    = 80
        protocol                = "Http"
        request_timeout         = 60
    }

    http_listener {
        name                           = local.http_listener_name
        frontend_ip_configuration_name = local.frontend_ip_configuration_name
        frontend_port_name             = local.frontend_port_name
        protocol                       = "Http"
    }

    request_routing_rule {
        priority                    = 5
        name                        = local.request_routing_rule_name
        rule_type                   = "Basic"
        http_listener_name          = local.http_listener_name
        backend_address_pool_name   = local.backend_address_pool_name
        backend_http_settings_name  = local.http_setting_name
    }

    identity {
        type         = "UserAssigned"
        identity_ids = [azurerm_user_assigned_identity.frontend.id]
    }

    //rewrite_rule_set {
    //  name = "remove-root"

    //  rewrite_rule {
    //    name = "remove-root"
    //    rule_sequence = 1

    //    condition {
    //        variable = "request_uri"
    //        pattern = "/{.*}{/|$}{.*}"
    //    }

    //    url {
    //        path = "/{var_uri_path_2}"
    //    }
    //  }
    //}
}

