##############################################
#         Container registry                 #
##############################################
/*
resource "azurerm_container_registry" "bee" {
  name                = "beenotice"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
}
*/

##############################################
#        Azure Kubernetes Service            #
##############################################
resource "azurerm_kubernetes_cluster" "tanzu" {
  name = "aks-${var.prefix}-${var.env}"

  resource_group_name = var.resource_group_name
  location            = var.location

  dns_prefix = "aks-tanzu"

  default_node_pool {
    name           = "tanzupool"
    node_count     = 2
    # az vm list-sizes --location "francecentral" -o table
    vm_size        = "Standard_A4m_v2"
    vnet_subnet_id = var.aks_subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "Standard"
  }
}

##############################################
#                 Roles                      #
##############################################
# Autorization to pull images from repository
/*
resource "azurerm_role_assignment" "hello_to_acr" {
  scope                = azurerm_container_registry.bee.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.tanzu.kubelet_identity[0].object_id
}
*/
