output "app_service_name" {
  value = azurerm_windows_web_app.app_service.name
}

output "app_service_default_hostname" {
  value = azurerm_windows_web_app.app_service.default_hostname
}

output "app_insights_instrumentation_key" {
  value     = azurerm_application_insights.app_insights.instrumentation_key
  sensitive = true
}

output "app_insights_connection_string" {
  value     = azurerm_application_insights.app_insights.connection_string
  sensitive = true
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}