/**
 *
 * # Key Vault module
 *
 * Creates Key Vault and assignes required permissions on it.
 */
resource "azurerm_key_vault" "key_vault" {
  name                = "kv-${var.name}"
  location            = var.location
  resource_group_name = var.rg_name

  purge_protection_enabled = false

  sku_name = "standard"

  enable_rbac_authorization = true
}
