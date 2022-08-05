# https://github.com/Tanzu-Solutions-Engineering/se-tap-bootcamps/tree/main/tap-up-and-running-bootcamp
# https://github.com/kennism/homelab/tree/main/tap

# Azure login
az login

# Set your default subscription
az account list --output table
az account set --subscription "subscription-id"
az account show --output table

# Preprare
# Add pod security policies support preview (required for learningcenter)
az extension add --name aks-preview
az feature register --name PodSecurityPolicyPreview --namespace Microsoft.ContainerService
# Wait until the status is "Registered"
az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/PodSecurityPolicyPreview')].{Name:name,State:properties.state}"
az provider register --namespace Microsoft.ContainerService