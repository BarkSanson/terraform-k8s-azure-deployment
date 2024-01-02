
variable "admin_login" {
    description = "The administrator login name for the MySQL Flexible Server."
}

variable "admin_password" {
    description = "The administrator login password for the MySQL Flexible Server."
}

variable "rg_name" {
    description = "The name of the resource group in which to create the MySQL Flexible Server."
}

variable "location" {
    description = "The location of the resource group in which to create the MySQL Flexible Server."
}

variable "db_subnet_id" {
    description = "The ID of the MySQL subnet"  
}