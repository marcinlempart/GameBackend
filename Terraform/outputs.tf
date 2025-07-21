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

output "ai_response_time_alert_id" {
  value       = azurerm_monitor_metric_alert.ai_response_time.id
  description = "ID of the Application Insights response time alert rule"
}

output "ai_request_count_alert_id" {
  value       = azurerm_monitor_metric_alert.ai_request_count.id
  description = "ID of the Application Insights request count alert rule"
}

output "ai_failed_requests_alert_id" {
  value       = azurerm_monitor_metric_alert.ai_failed_requests.id
  description = "ID of the Application Insights failed requests alert rule"
}

output "ai_exceptions_alert_id" {
  value       = azurerm_monitor_metric_alert.ai_exceptions.id
  description = "ID of the Application Insights exceptions alert rule"
}

output "alert_email" {
  value       = var.alert_email
  description = "Email address configured for alerts"
}

output "application_insights_id" {
  value       = azurerm_application_insights.app_insights.id
  description = "ID of the Application Insights resource"
}

output "application_insights_app_id" {
  value       = azurerm_application_insights.app_insights.app_id
  description = "App ID of the Application Insights resource"
}