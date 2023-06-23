output "backend_url" {
  value = azurerm_linux_web_app.main.default_hostname
}
