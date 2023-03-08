###########################################
# Deployment
###########################################
# Path to tanzu-tools files
TANZU_TOOLS_FILES_PATH="/mnt/c/Dev/workspaces/tanzu-tools/"
# Path to k8s deployment files
K8S_FILES_PATH="$TANZU_TOOLS_FILES_PATH/k8s/"
# Namespace to deploy tanzu package
# Kapp-controller is configured to share all packages within the “tanzu-package-repo-global” namespace cluster-wide
USER_PACKAGE_NAMESPACE="tanzu-package-repo-global"

# Name of the user in the jumpbox VM
VM_USER=fmartin

# https://kubernetes.io/releases/
KUBECTL_VERSION=v1.21.7

# Harbor
# kubectl get httpproxy -A in the shared cluster
HARBOR_URL=harbor.haas-467.pez.vmware.com
NOTARY_URL=notary.harbor.haas-467.pez.vmware.com

###########################################
# Package versions
###########################################
GRAFANA_VERSION="7.5.7+vmware.2-tkg.1"
PROMETHEUS_VERSION="2.27.0+vmware.2-tkg.1"
CONTOUR_VERSION="1.18.2+vmware.1-tkg.1"
CERT_MANAGER_VERSION="1.5.3+vmware.2-tkg.1"
FLUENT_BIT_VERSION="1.7.5+vmware.1-tkg.1"
HARBOR_VERSION="2.2.3+vmware.1-tkg.1"
