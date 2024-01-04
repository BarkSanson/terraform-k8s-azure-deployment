output "appgw_id" {
    value = azurerm_application_gateway.asi_gw.id
}

output "appgw_assigned_identity" {
    value = azurerm_user_assigned_identity.asi_gw.id
}