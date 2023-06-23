output "backend_url" {
  value = azurerm_linux_web_app.main.default_hostname
}

output "tenant_id" {
  value = data.azuread_client_config.current.tenant_id
}

output "subscription_id" {
  value = data.azurerm_subscription.primary.id
}

output "subscription_name" {
  value = data.azurerm_subscription.primary.display_name
}

### App Reg ###

output "serviceprincipal_object_id" {
  value = azuread_service_principal.ado_service_connector.object_id
}

output "application_id" {
  value = azuread_application.ado_service_connector.application_id
}

output "application_object_id" {
  value = azuread_application.ado_service_connector.object_id
}
