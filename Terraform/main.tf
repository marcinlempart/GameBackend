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

# Alert - Wysoka liczba GET / requests w ciągu 24h
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "high_get_requests" {
  name                = "${var.app_name}-high-get-requests"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  evaluation_frequency = "PT5M"  # Sprawdzaj co 5 minut
  window_duration      = "P1D"   # Okno czasowe 24 godziny (1 dzień)
  scopes               = [azurerm_application_insights.app_insights.id]
  severity             = 2

  criteria {
    query                   = <<-QUERY
      requests
      | where url contains "/"
      | where name == "GET /"
      | where resultCode == "307"
      | where timestamp >= ago(24h)
      | summarize TotalRequestCount = count()
    QUERY
    time_aggregation_method = "Total"
    threshold               = 10
    operator                = "GreaterThanOrEqual"
    metric_measure_column   = "TotalRequestCount"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.app_alerts.id]
  }

  description = "Alert gdy aplikacja otrzyma 10 lub więcej GET / requests (kod 307) w ciągu ostatnich 24 godzin - sprawdzane co 5 minut"
  enabled     = true
}