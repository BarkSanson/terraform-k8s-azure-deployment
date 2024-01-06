variable "rg_name" {
    description = "The name of the resource group to deploy the AKS cluster into"
    type        = string
}

variable "rg_id" {
    description = "The ID of the resource group to deploy the AKS cluster into"
    type        = string
}

variable "location" {
    description = "The location of the resource group to deploy the AKS cluster into"
    type        = string
}

variable "appgw_id" {
    description = "The ID of the Application Gateway to use for the AKS cluster"
    type        = string 
}

variable "appgw_identity_id" {
    description = "The ID of the Application Gateway identity to use for the AKS cluster"
    type        = string 
}

variable "aks_subnet_id" {
    description = "The ID of the subnet to deploy the AKS cluster into"
    type        = string
}

variable "acr_id" {
    description = "The ID of the ACR to use for the AKS cluster"
    type        = string
}

variable "key_vault_id" {
    description = "The ID of the Key Vault to use for the AKS cluster"
    type        = string
}

variable "appgw_subnet_id" {
    description = "The ID of the subnet to deploy the Application Gateway into"
    type        = string 
}