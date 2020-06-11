variable "azurerm_virtual_machine_id" {
    type = string
    description = "Azure virtual machine ID. Typically [azurerm_virtual_machine.main.id]"
}
variable "azurerm_storage_account_name" {
    type = string
    description = "Azure storage account name to store the diagnostics. Typically [azurerm_storage_account.main.name]"
}
variable "azurerm_storage_account_primary_connection_string" {
    type = string
    description = "Azure storage account connection string. Typically [azurerm_storage_account.main.primary_connection_string]"
}
variable "provision" {
    type = bool
    description = "Whether or not to provision the module. This should be replaced with count in terraform .13"
    default = true
}