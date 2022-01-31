###########################################
# Deployment
###########################################
# Path to tanzu-tools files
TANZU_TOOLS_FILES_PATH="/mnt/workspaces/tanzu-tools"
# Path to k8s deployment files
K8S_FILES_PATH="$TANZU_TOOLS_FILES_PATH/k8s/"
# Namespace to deploy tanzu package
USER_PACKAGE_NAMESPACE="tanzu-user-managed-packages"

# Harbor
# kubectl get httpproxy -A in the shared cluster
HARBOR_URL=harbor.haas-478.pez.vmware.com
NOTARY_URL=notary.harbor.haas-478.pez.vmware.com

###########################################
# Package versions
###########################################
GRAFANA_VERSION="7.5.7+vmware.1-tkg.1"
PROMETHEUS_VERSION="2.27.0+vmware.1-tkg.1"
CONTOUR_VERSION="1.17.1+vmware.1-tkg.1"
CERT_MANAGER_VERSION="1.1.0+vmware.1-tkg.2"
FLUENT_BIT_VERSION="1.7.5+vmware.1-tkg.1"
HARBOR_VERSION="2.2.3+vmware.1-tkg.1"
