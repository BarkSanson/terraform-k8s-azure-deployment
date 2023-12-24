terraform {
    required_version = ">= 0.14"

    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = ">= 3.85.0"
        }
    }
}