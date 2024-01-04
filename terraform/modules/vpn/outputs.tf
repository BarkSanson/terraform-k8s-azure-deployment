output "vnet_id" {
  value = azurerm_virtual_network.asi_vnet.id
}

output "appgw_vnet_id" {
  value = azurerm_virtual_network.app_gw.id
}

output "db_subnet_id" {
  value = azurerm_subnet.db_subnet.id
}

output "aks_subnet_id" {
  value = azurerm_subnet.aks_subnet.id
}

output "appgw_subnet_id" {
  value = azurerm_subnet.appgw_subnet.id
}
