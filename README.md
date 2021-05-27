# terraform-azurerm-acr

## Deploys an Azure Container Registry

This Terraform module creates an Azure Container Registry with supporting resources in Azure.

### NOTES

* Default SKU Tier is set to Basic
* Default Trust Policy is set to false
* Default Admin user enable is set to false

## Usage in Terraform 0.15

```terraform
module "acr" {
  source                = "git@ssh.dev.azure.com:v3/raet/IT%20Operations/ name                      = var.acr_name
  resource_group_name       = var.acr_rsg
  create_resource_group     = var.create_resource_group
  location                  = var.location
  sku                       = var.acr_sku
  georeplication_location   = var.georeplication_location
  content_trust             = var.content_trust
  admin_enabled             = var.admin_enabled
  quarantine_policy_enabled = var.quarantine_policy_enabled
  retention_policy = {
    days        = 5
    enabled = true
  }
```

In case you specifiy to enable user admin you can store the sensitive user&password in a secret vault. Make use of the [Key Vault](https://github.com/visma-raet/terraform-azurerm-keyvault) module for this.

```terraform
module "keyvault" {
  source = "git@github.com:visma-raet/terraform-azurerm-keyvault.git"

  name                  = var.keyv_name
  resource_group_name   = var.acr_rsg
  location              = var.location
  create_resource_group = true

  access_policies = [
    {
      object_id               = data.azurerm_client_config.current.object_id
      secret_permissions      = ["get", "list", "set", "delete", "purge", "restore"]
      storage_permissions     = []
      key_permissions         = []
      certificate_permissions = []
    }
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
