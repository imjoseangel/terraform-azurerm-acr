#---------------------------------------------------------
# Outputs
#---------------------------------------------------------
output "id" {
  description = "The Container Registry ID"
  value       = azurerm_container_registry.acr.id
}

output "admin_username" {
  value       = azurerm_container_registry.acr.admin_username
  description = "The Username associated with the Container Registry Admin account"
  sensitive   = true
}

output "admin_password" {
  value       = azurerm_container_registry.acr.admin_password
  description = "The Password associated with the Container Registry Admin account "
  sensitive   = true
}

output "login_server" {
  description = "The URL that can be used to log into the container registry."
  value       = azurerm_container_registry.acr.login_server
}
