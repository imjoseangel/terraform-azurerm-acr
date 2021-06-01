# terraform-azurerm-acr

## Deploys a Azure Container Registry

This Terraform module creates a Azure Container Registry with supporting resources in Azure.

### NOTES

* Default SKU Tier is set to Basic
* Default Trust Policy is set to false
* Default Admin user enable is set to false
* Default Encryption is set to false
* Content trust is currently not supported in a registry encrypted.

## Usage in Terraform 0.15

```terraform
module "acr" {
  source                  = "github.com/visma-raet/terraform-azurerm-acr"
  name                    = var.acr_name
  resource_group_name     = var.acr_rsg
  create_resource_group   = var.create_resource_group
  location                = var.location
  sku                     = var.acr_sku
  georeplication_location = var.georeplication_location
  content_trust           = var.content_trust
  admin_enabled           = var.admin_enabled

  encryption = {
    enabled            = var.encryption_enabled
    key_vault_key_id   = azurerm_key_vault_key.keygenerated.id
    identity_client_id = data.azurerm_user_assigned_identity.uaiacr.client_id
  }
  quarantine_policy_enabled = var.quarantine_policy_enabled
   = {
    days    = 5
    enabled = true
  }

  roles = [
    {
      ppal_id = "${data.azurerm_client_config.current.object_id}"
      role    = "AcrImageSigner"
    },
  ]

  depends_on = [
    module.keyvault
  ]
}
```

User Managed identities are set with **identity_id** attribute. The module generate a System Managed Identity automatically but user managed ID can
be assigned with this attribute.retention_policy

```terraform
#Create User-Managed Identity

data "azurerm_user_assigned_identity" "uaiacr" {
  name                = format("%s-uai", var.acr_name)
  resource_group_name = var.acr_rsg
}

  identity_id         = data.azurerm_user_assigned_identity.uaiacr.id
```

To Enable push and pull signed images (content trust) set **content_trust** attribute to true. If you enable it, encryption option automatically will be set to false.

To enable registry content encryption you must set the the customer-managed key created in key vault **key_vault_key_id** and the user-assigned managed identity **identity_client_id** to access to the key vault.

```terraform
#Create KeyVault Key
resource "azurerm_key_vault_key" "keygenerated" {
  name         = "generated-key"
  key_vault_id = module.keyvault.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  depends_on = [
    module.keyvault
  ]
}
```

To enable quarantine feature set the attribute **quarantine_policy_enabled** (Premium SKU needed). New images that are published are automatically quarantined and are not available for general use.

To define a retention policy for storage image untagged manifest, use the attribute **retention_policy**. When a retention policy is enabled, untagged manifests in the registry are automatically deleted after a number of days you set.

```terraform
retention_policy = {
    days    = 5
    enabled = true
  }
```

In case you specify to enable user admin you can store the sensitive user&password in a secret vault. Make use of the [Key Vault](https://github.com/visma-raet/terraform-azurerm-keyvault) module for all the attributes commented above.

```terraform
module "keyvault" {
  source = "github.com/visma-raet/terraform-azurerm-keyvault"

  name                  = var.keyv_name
  resource_group_name   = var.acr_rsg
  location              = var.location
  create_resource_group = false

  access_policies = [
    {
      object_id               = data.azurerm_client_config.current.object_id
      secret_permissions      = ["get", "list", "set", "delete", "purge", "restore"]
      storage_permissions     = []
      key_permissions         = ["create", "list", "get", "purge", "recover", "delete", "UnwrapKey", "WrapKey"]
      certificate_permissions = []
    },
    {
      object_id               = data.azurerm_user_assigned_identity.uaiacr.principal_id
      secret_permissions      = ["get", "list", "set", "delete", "purge", "restore"]
      storage_permissions     = []
      key_permissions         = ["create", "list", "get", "purge", "recover", "delete", "UnwrapKey", "WrapKey"]
      certificate_permissions = []
    }
  ]
}

resource "azurerm_key_vault_secret" "acrstorage" {
  name         = module.acr.admin_username
  value        = module.acr.admin_password
  key_vault_id = module.keyvault.id
}

resource "azurerm_role_assignment" "uaiacr_role" {
  scope                = module.keyvault.id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_user_assigned_identity.uaiacr.principal_id
}

resource "azurerm_key_vault_key" "keygenerated" {
  name         = "generated-key"
  key_vault_id = module.keyvault.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  depends_on = [
    module.keyvault
  ]
}

resource "azurerm_key_vault_secret" "acrstorage" {
  name         = module.acr.admin_username
  value        = module.acr.admin_password
  key_vault_id = module.keyvault.id
}

```

## Authors

Originally created by [Visma-raet](http://github.com/visma-raet)

## License

[MIT](LICENSE)
