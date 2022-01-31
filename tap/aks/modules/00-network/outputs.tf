output "aks_subnet_id" {
  description = "The AKS subnet id"
  value       = azurerm_subnet.aks.id
}
