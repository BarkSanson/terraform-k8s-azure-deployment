variable "rg_name" {
    description = "The name of the resource group in which to create the key vault."
}

variable "location" {
    description = "The location of the resource group in which to create the key vault."
}

variable "tenant_id" {
    description = "The tenant ID of the Azure Active Directory tenant used for authenticating requests to the key vault."
}

variable "object_id" {
    description = "The object ID of the Azure Active Directory principal used for authenticating requests to the key vault."
}

variable "aks_subnet_id" {
    description = "The ID of the AKS subnet" 
}

variable "admin_login" {
    description = "The administrator username of the MySQL server." 
}

variable "admin_password" {
    description = "The administrator password of the MySQL server." 
}