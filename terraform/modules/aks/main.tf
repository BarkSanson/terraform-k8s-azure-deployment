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
        gateway_id = var.appgw_id
    }
}

resource "azurerm_role_assignment" "aks_acr_connector" {
    principal_id         = azurerm_kubernetes_cluster.asi.kubelet_identity[0].object_id
    scope                = var.acr_id
    role_definition_name = "AcrPull"
}

data "azurerm_user_assigned_identity" "aks_ingress_appgw" {
    name                = "ingressapplicationgateway-${azurerm_kubernetes_cluster.asi.name}"
    resource_group_name = azurerm_kubernetes_cluster.asi.node_resource_group
}

resource "azurerm_role_assignment" "aks_appgw_connector" {
    principal_id         = data.azurerm_user_assigned_identity.aks_ingress_appgw.principal_id
    scope                = var.appgw_id
    role_definition_name = "Contributor"
}

resource "azurerm_role_assignment" "aks_appgw_rg_reader" {
    principal_id         = data.azurerm_user_assigned_identity.aks_ingress_appgw.principal_id
    scope                = var.rg_id
    role_definition_name = "Reader"
}

resource "azurerm_role_assignment" "aks_appgw_identity_contributor" {
    principal_id         = data.azurerm_user_assigned_identity.aks_ingress_appgw.principal_id
    scope                = var.appgw_identity_id
    role_definition_name = "Contributor"
}

resource "azurerm_role_assignment" "aks_vpn_contributor" {
    principal_id         = data.azurerm_user_assigned_identity.aks_ingress_appgw.principal_id
    scope                = var.appgw_subnet_id
    role_definition_name = "Network Contributor"
}

data "azurerm_user_assigned_identity" "aks_kv" {
    name                = "azurekeyvaultsecretsprovider-${azurerm_kubernetes_cluster.asi.name}"
    resource_group_name = azurerm_kubernetes_cluster.asi.node_resource_group
}

resource "azurerm_role_assignment" "aks_kv_connector" {
    principal_id         = data.azurerm_user_assigned_identity.aks_kv.principal_id
    scope                = var.key_vault_id
    role_definition_name = "Key Vault Administrator"
}
