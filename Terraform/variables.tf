variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-game-backend"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West Europe"
}

variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "game-backend-app"
}

variable "alert_email" {
  description = "Email address for receiving alerts"
  type        = string
  default     = "your-email@example.com"  # Zmień na swój email
}

# Optional: Add subscription_id variable if you need to explicitly set it
# variable "subscription_id" {
#   description = "Azure subscription ID"
#   type        = string
#   sensitive   = true
# }