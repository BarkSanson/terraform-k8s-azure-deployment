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

variable "aks_subnet_id" {
    description = "The ID of the subnet to deploy the AKS cluster into"
    type        = string
}

variable "agic_subnet_id" {
    description = "The ID of the subnet to deploy the AGIC into"
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