resource "azurerm_storage_account" "asistorageuib" {
    name                     = "asistorageuib"
    resource_group_name      = var.rg_name
    location                 = var.location
    account_tier             = "Standard"
    account_replication_type = "LRS"

    enable_https_traffic_only = false

    static_website {
        index_document = "pagina.html"
    }
}

resource "azurerm_storage_blob" "index" {
    name = "pagina.html"
    storage_account_name = azurerm_storage_account.asistorageuib.name
    storage_container_name = "$web"
    type = "Block"
    content_type = "text/html"
    source = "../web/pagina.html"
}

resource "azurerm_storage_blob" "logo" {
    name = "R.png"
    storage_account_name = azurerm_storage_account.asistorageuib.name
    storage_container_name = "$web"
    type = "Block"
    source = "../web/R.png"
}

resource "azurerm_storage_blob" "script" {
    name = "queries.js"
    storage_account_name = azurerm_storage_account.asistorageuib.name
    storage_container_name = "$web"
    type = "Block"
    content_type = "application/javascript"
    source = "../web/queries.js"
}