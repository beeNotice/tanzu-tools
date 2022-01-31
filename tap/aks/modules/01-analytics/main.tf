##############################################
#                Workspace                  #
##############################################
resource "random_id" "workspace" {
  byte_length = 8
}

resource "azurerm_log_analytics_workspace" "tanzu" {
  name                = "log-${var.prefix}-${random_id.workspace.hex}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "PerGB2018"
}

##############################################
#             AKS supervision                #
##############################################
resource "azurerm_log_analytics_solution" "container" {
  solution_name         = "ContainerInsights"
  resource_group_name   = var.resource_group_name
  location              = var.location
  workspace_resource_id = azurerm_log_analytics_workspace.tanzu.id
  workspace_name        = azurerm_log_analytics_workspace.tanzu.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}
