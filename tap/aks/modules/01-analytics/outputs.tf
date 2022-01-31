output "log_analytics_workspace_id" {
  description = "The workspace id"
  value       = azurerm_log_analytics_workspace.tanzu.id
}
