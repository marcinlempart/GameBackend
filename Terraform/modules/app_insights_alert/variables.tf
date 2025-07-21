
variable "alert_name" {
  description = "Nazwa alertu"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group dla Application Insights"
  type        = string
}

variable "app_insights_name" {
  description = "Nazwa Application Insights"
  type        = string
}

variable "alert_email_group_1" {
  description = "Obowiązkowa grupa mailowa"
  type        = string
}

variable "alert_email_group_2" {
  description = "Opcjonalna grupa mailowa 2"
  type        = string
  default     = ""
}

variable "alert_email_group_3" {
  description = "Opcjonalna grupa mailowa 3"
  type        = string
  default     = ""
}

variable "alert_threshold" {
  description = "Próg uruchomienia alertu"
  type        = number
}
