# terraform-linuxdiagnostic-agent-module
Module to deploy Linux Diagnostic Module from terraform

# Usage
```
//=== Virtual Machine ===//
resource "azurerm_virtual_machine" "main" {
   ...
}

//=== Storage Account ===//
resource "azurerm_storage_account" "main" {
   ...
}

//== Linux Diagnostic ==//
module "vm_extension_linux_diagnostic" {
  source = "/modules/Azure-VMExtensions-LinuxDiagnostic/v1"

  azurerm_virtual_machine_id = azurerm_virtual_machine.main.id
  azurerm_storage_account_name = var.stackSettings.azurerm_storage_account.name
  azurerm_storage_account_primary_connection_string = var.stackSettings.azurerm_storage_account.primary_connection_string
}
```
