variable "rg_name" {
    type = string
    description = "Name of the resource group"
}

variable "location" {
    type = string
    description = "Location of the resource group" 
}

variable "subnet_id" {
    type = string
    description = "ID of the subnet for the AppGW"
}