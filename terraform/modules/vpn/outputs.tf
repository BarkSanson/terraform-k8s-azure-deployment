output "backend_vnet_id" {
  value = azurerm_virtual_network.backend.id
}

output "frontend_vnet_id" {
  value = azurerm_virtual_network.frontend.id
}

output "db_vnet_id" {
  value = azurerm_virtual_network.db.id 
}

output "db_subnet_id" {
  value = azurerm_subnet.db.id
}

output "aks_subnet_id" {
  value = azurerm_subnet.aks.id
}

output "frontend_subnet_id" {
  value = azurerm_subnet.frontend.id
}
