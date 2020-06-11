/**
Linux Diagnostic Agent
The linux diagnostic agent is rather complicated to get working.
You need:
1. A static timestamp for start/expiry time
2. A SAS token from the storage account with custom permissions
3. Importing multiple large jsons with custom cleanup
This is taken care of for everything below
**/

//== Provider used to store timestamp SAS token lifetime ==//
provider "time" {
  version = "~> 0.4"
}

//== Store 10 years in the future ==//
resource "time_offset" "sas_expiry" {
  offset_years = 10
}

//== Store (now - 10) days to ensure we have valid SAS ==//
resource "time_offset" "sas_start" {
  offset_days = -10
}

//== SAS Token required for Diagnostic Extension ==//
/**
The permissions are based on the linux powershell sas creation here: https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/diagnostics-linux
**/
data "azurerm_storage_account_sas" "token" {
  connection_string = var.azurerm_storage_account_primary_connection_string
  https_only        = true

  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob  = true
    table = true
    queue = false
    file = false
  }

  start  = time_offset.sas_start.rfc3339
  expiry = time_offset.sas_expiry.rfc3339

  permissions {
    read    = true
    write   = true
    delete  = true
    list    = true
    add     = true
    create  = true
    update  = true
    process = true
  }
}

//=== Install Diagnostic Extension ===//
resource "azurerm_virtual_machine_extension" "diagnostics" {
  count                      = var.provision ? 1 : 0
  name                       = "LinuxDiagnostic"
  virtual_machine_id         =  var.azurerm_virtual_machine_id
  publisher                  = "Microsoft.Azure.Diagnostics"
  type                       = "LinuxDiagnostic"
  type_handler_version       = "3.0"
  auto_upgrade_minor_version = "true"

  settings = <<SETTINGS
    {
      "StorageAccount": "${var.azurerm_storage_account_name}",
      "ladCfg": {
          "diagnosticMonitorConfiguration": {
                "eventVolume": "Medium", 
                "metrics": {
                     "metricAggregation": [
                        {
                            "scheduledTransferPeriod": "PT1H"
                        }, 
                        {
                            "scheduledTransferPeriod": "PT1M"
                        }
                    ], 
                    "resourceId": "${var.azurerm_virtual_machine_id}"
                },
                "performanceCounters": ${file("${path.module}/configs/performancecounters.json")},
                "syslogEvents": ${file("${path.module}/configs/syslogevents.json")}
          }, 
          "sampleRateInSeconds": 15
      }
    }
  SETTINGS

  protected_settings = <<SETTINGS
    {
        "storageAccountName": "${var.azurerm_storage_account_name}",
        "storageAccountSasToken": "${data.azurerm_storage_account_sas.token.sas}",
        "storageAccountEndPoint": "https://core.windows.net",
         "sinksConfig":  {
              "sink": [
                {
                    "name": "SyslogJsonBlob",
                    "type": "JsonBlob"
                },
                {
                    "name": "LinuxCpuJsonBlob",
                    "type": "JsonBlob"
                }
              ]
        }
    }
    SETTINGS
}