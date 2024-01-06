output "appgw_identity_id" {
  value = azurerm_user_assigned_identity.frontend.id
}

output "appgw_id" {
    value = azurerm_application_gateway.frontend.id
}