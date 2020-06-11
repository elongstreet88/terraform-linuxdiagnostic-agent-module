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
  source = "github.com/elongstreet88/terraform-linuxdiagnostic-agent-module"

  azurerm_virtual_machine_id                        = azurerm_virtual_machine.main.id
  azurerm_storage_account_name                      = azurerm_storage_account.main.name
  azurerm_storage_account_primary_connection_string = azurerm_storage_account.main.primary_connection_string
}
```
