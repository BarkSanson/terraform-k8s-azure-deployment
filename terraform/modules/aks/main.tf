locals {
    backend_address_pool_name       = "asi-gw-pool"
    frontend_port_name              = "asi-gw-port"
    frontend_ip_configuration_name  = "asi-gw-ip"
    http_setting_name               = "asi-gw-settings"
    http_listener_name              = "asi-gw-listener"
    request_routing_rule_name       = "asi-gw-rule"
}

resource "azurerm_user_assigned_identity" "agic" {
    name = "agic-gw"
    resource_group_name = var.rg_name
    location = var.location
}

resource "azurerm_public_ip" "agic" {
    name = "asi"
    resource_group_name = var.rg_name
    location = var.location
    allocation_method = "Static"
    sku = "Standard"
    domain_name_label = "asi"
}

resource "azurerm_application_gateway" "agic" {
    name = "agic"
    resource_group_name = var.rg_name
    location = var.location

    sku {
        name = "Standard_v2"
        tier = "Standard_v2"
        capacity = 2
    }

    gateway_ip_configuration {
        name = "asi-ip-config"
        subnet_id = var.agic_subnet_id
    }

    frontend_port {
        name = local.frontend_port_name
        port = 80
    }

    frontend_ip_configuration {
        name = local.frontend_ip_configuration_name
        public_ip_address_id = azurerm_public_ip.agic.id
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
        identity_ids = [azurerm_user_assigned_identity.agic.id]
    }

    rewrite_rule_set {
      name = "remove-root"

      rewrite_rule {
        name = "remove-root"
        rule_sequence = 1

        condition {
            variable = "request_uri"
            pattern = "/{.*}{/|$}{.*}"
        }

        url {
            path = "/{var_uri_path_2}"
        }
      }
    }

}

resource "azurerm_kubernetes_cluster" "asi" {
    name                = "asi"
    resource_group_name = var.rg_name
    location            = var.location
    dns_prefix          = "asi"

    default_node_pool {
        name            = "default"
        node_count      = 1
        vm_size         = "Standard_B2s"
        vnet_subnet_id  = var.aks_subnet_id
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
        gateway_id = azurerm_application_gateway.agic.id
    }
}

resource "azurerm_role_assignment" "aks-acr-connector" {
    principal_id         = azurerm_kubernetes_cluster.asi.kubelet_identity[0].object_id
    scope                = var.acr_id
    role_definition_name = "AcrPull"
}

data "azurerm_user_assigned_identity" "aks_ingress_agic" {
    name                = "ingressapplicationgateway-${azurerm_kubernetes_cluster.asi.name}"
    resource_group_name = azurerm_kubernetes_cluster.asi.node_resource_group
}

resource "azurerm_role_assignment" "aks_agic_connector" {
    principal_id         = data.azurerm_user_assigned_identity.aks_ingress_agic.principal_id
    scope                = azurerm_application_gateway.agic.id
    role_definition_name = "Contributor"
}

resource "azurerm_role_assignment" "aks_agic_rg_reader" {
    principal_id         = data.azurerm_user_assigned_identity.aks_ingress_agic.principal_id
    scope                = var.rg_id
    role_definition_name = "Reader"
}

resource "azurerm_role_assignment" "aks_appgw_identity_contributor" {
    principal_id         = data.azurerm_user_assigned_identity.aks_ingress_agic.principal_id
    scope                = azurerm_user_assigned_identity.agic.id
    role_definition_name = "Contributor"
}

resource "azurerm_role_assignment" "aks_vpn_contributor" {
    principal_id         = data.azurerm_user_assigned_identity.aks_ingress_agic.principal_id
    scope                = var.agic_subnet_id
    role_definition_name = "Network Contributor"
}


data "azurerm_user_assigned_identity" "aks_kv" {
    name                = "azurekeyvaultsecretsprovider-${azurerm_kubernetes_cluster.asi.name}"
    resource_group_name = azurerm_kubernetes_cluster.asi.node_resource_group
}

resource "azurerm_role_assignment" "aks-kv-connector" {
    principal_id         = data.azurerm_user_assigned_identity.aks_kv.principal_id
    scope                = var.key_vault_id
    role_definition_name = "Key Vault Administrator"
}
