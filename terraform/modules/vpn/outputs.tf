output "aks_vnet_id" {
  value = azurerm_virtual_network.aks.id
}

output "appgw_vnet_id" {
  value = azurerm_virtual_network.appgw.id
}

output "db_subnet_id" {
  value = azurerm_subnet.db.id
}

output "aks_subnet_id" {
  value = azurerm_subnet.aks.id
}

output "agic_subnet_id" {
  value = azurerm_subnet.agic.id
}
