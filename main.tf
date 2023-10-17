resource "azurerm_storage_account" "my_storage_account" {
  name                     = "diag${random_id.random_id.hex}"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"

  encryption {
    services {
      blob = {
        enabled = true
        key_type = "Account"
        key_source = "Microsoft.Storage"
      }
      file = {
        enabled = true
        key_type = "Account"
        key_source = "Microsoft.Storage"
      }
      table = {
        enabled = true
        key_type = "Account"
        key_source = "Microsoft.Storage"
      }
      queue = {
        enabled = true
        key_type = "Account"
        key_source = "Microsoft.Storage"
      }
    }

    key_vault_properties {
      key_vault_uri = azurerm_key_vault.example.vault_uri
      key_name      = "your-key-name" # Replace with your key name in Key Vault
      key_version   = ""               # You can specify a version or leave it empty for the latest
    }
  }

  tags = {
    environment = "production"
  }
}

resource "azurerm_key_vault" "example" {
  name                        = "your-key-vault-name"
  resource_group_name         = azurerm_resource_group.rg.name
  location                    = azurerm_resource_group.rg.location
  sku_name                    = "standard"
  tenant_id                   = data.azuread_tenant.current.id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  enabled_for_disk_encryption = true
}
