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

output "alert_action_group_id" {
  value       = azurerm_monitor_action_group.app_alerts.id
  description = "ID of the action group for alerts"
}

output "get_requests_alert_id" {
  value       = azurerm_monitor_scheduled_query_rules_alert_v2.high_get_requests.id
  description = "ID of the GET requests alert rule"
}

output "alert_email" {
  value       = var.alert_email
  description = "Email address configured for alerts"
}