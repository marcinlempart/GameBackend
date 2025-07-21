
module "app_insights_alert" {
  source              = "./modules/app_insights_alert"
  alert_name          = "my-app-insights-alert"
  resource_group_name = var.resource_group_name
  app_insights_name   = var.app_insights_name
  alert_email_group_1 = var.alert_email_group_1
  alert_email_group_2 = var.alert_email_group_2
  alert_email_group_3 = var.alert_email_group_3
  alert_threshold     = var.alert_threshold
}
