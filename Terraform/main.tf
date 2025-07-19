terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  
  # Optional: Add backend configuration for remote state
  # backend "azurerm" {
  #   resource_group_name  = "terraform-state-rg"
  #   storage_account_name = "terraformstatestorage"
  #   container_name      = "tfstate"
  #   key                = "game-backend.tfstate"
  # }
}

provider "azurerm" {
  features {}
  # The subscription_id will be automatically detected from Azure CLI context
  # or you can explicitly set it if needed:
  # subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Updated to use the new azurerm_service_plan resource
resource "azurerm_service_plan" "app_plan" {
  name                = "${var.app_name}-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Windows"
  sku_name           = "S1"
}

# Updated to use the new azurerm_windows_web_app resource
resource "azurerm_windows_web_app" "app_service" {
  name                = var.app_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.app_plan.id

  site_config {
    always_on = true
    application_stack {
      dotnet_version = "v6.0" # Adjust based on your .NET version
    }
  }

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"             = azurerm_application_insights.app_insights.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING"      = azurerm_application_insights.app_insights.connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
    "WEBSITE_RUN_FROM_PACKAGE"                  = "1"
  }
}

resource "azurerm_application_insights" "app_insights" {
  name                = "${var.app_name}-insights"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}

# Action Group dla alertów (gdzie wysyłać notyfikacje)
resource "azurerm_monitor_action_group" "app_alerts" {
  name                = "${var.app_name}-action-group"
  resource_group_name = azurerm_resource_group.rg.name
  short_name          = "gameapp"

  email_receiver {
    name          = "email-alert"
    email_address = var.alert_email
  }
}

# Alert na Application Insights - Server Response Time
resource "azurerm_monitor_metric_alert" "ai_response_time" {
  name                = "${var.app_name}-ai-response-time"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_application_insights.app_insights.id]
  description         = "Alert when Application Insights detects high response time"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "requests/duration"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 5000  # 5 sekund w milisekundach

    dimension {
      name     = "request/resultCode"
      operator = "Include"
      values   = ["*"]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.app_alerts.id
  }
}

# Alert na Application Insights - Request Count
resource "azurerm_monitor_metric_alert" "ai_request_count" {
  name                = "${var.app_name}-ai-request-count"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_application_insights.app_insights.id]
  description         = "Alert when Application Insights detects high request count"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "requests/count"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 10  # 10 requestów w 15 minut

    dimension {
      name     = "request/resultCode"
      operator = "Include"
      values   = ["307"]  # Specific dla kodu 307
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.app_alerts.id
  }
}

# Alert na Application Insights - Failed Requests
resource "azurerm_monitor_metric_alert" "ai_failed_requests" {
  name                = "${var.app_name}-ai-failed-requests"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_application_insights.app_insights.id]
  description         = "Alert when Application Insights detects failed requests"
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "requests/failed"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 5  # 5 nieudanych requestów

    dimension {
      name     = "request/resultCode"
      operator = "Include"
      values   = ["*"]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.app_alerts.id
  }
}