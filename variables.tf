#-------------------------------
# Common Variables
#-------------------------------
variable "location" {
  type        = string
  default     = "westeurope"
  description = "Name of the default object location."
}

variable "tf_name" {
  type        = string
  default     = "terraform"
  description = "Name of the terraform object."
}

#-------------------------------
# ACR Variables
#-------------------------------

variable "name" {
  type        = string
  description = "Name of the Azure Container Registry."
}

variable "sku" {
  type        = string
  default     = "Basic"
  description = "The SKU name of the container registry."
}

variable "resource_group_name" {
  type        = string
  default     = "acr-resource-group"
  description = "Name of the Azure Container Registry resource group."
}

variable "create_resource_group" {
  description = "Whether to create resource group and use it for all networking resources"
  default     = true
}

variable "encryption_enabled" {
  type        = bool
  description = "Specifies whether the encryption useoptionr is enabled."
  default     = false
}

variable "key_vault_key_id" {
  type        = string
  description = "The ID of the Key Vault Key."
  default     = null
}

variable "identity_client_id" {
  type        = string
  description = "The client ID of the managed identity associated with the encryption key."
  default     = null
}

variable "identity_id" {
  type        = string
  description = "The user assigned identity ID of the managed identity associated with the encryption key."
  default     = null
}

variable "admin_enabled" {
  description = "Specifies whether the admin user is enabled."
  type        = bool
  default     = false
}

variable "quarantine_policy_enabled" {
  description = "Indicates whether quarantine policy is enabled."
  type        = bool
  default     = false
}

variable "retention_policy" {
  type        = map(string)
  description = "If enabled define the numebr of days to retain an untagged manifest after which it gets purged"
  default = {
    days    = 7
    enabled = false
  }
}

variable "roles" {
  description = "List of roles that should be assigned to sppal."
  type        = list(object({ ppal_id = string, role = string }))
  default     = []
}

variable "content_trust" {
  description = "Enable Docker Content Trust on ACR."
  type        = bool
  default     = false
}

variable "georeplication_location" {
  description = "The Azure location where the container registry should be geo-replicated (sku must be Premium)."
  type        = string
  default     = "West Europe"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
