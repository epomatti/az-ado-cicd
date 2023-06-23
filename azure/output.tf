output "backend_url" {
  value = azurerm_linux_web_app.main.default_hostname
}

output "azuread_application_password" {
  value     = azuread_application_password.ado_service_connector.value
  sensitive = true
}
