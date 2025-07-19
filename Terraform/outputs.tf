output "app_service_name" {
  value = azurerm_app_service.app_service.name
}

output "app_service_default_hostname" {
  value = azurerm_app_service.app_service.default_site_hostname
}

output "app_insights_instrumentation_key" {
  value = azurerm_application_insights.app_insights.instrumentation_key
}
