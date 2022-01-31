HARBOR_USER=
HARBOR_PASS=

###########################################
# Jumpbox
###########################################
# Name of the user in the jumpbox VM
VM_USER=tanzu
# Folder to put cli binaries
BIN_FOLDER=/usr/local/bin/
# https://network.pivotal.io/products/build-service/
KP_URL=

BUILD_SERVICE_NAMESPACE=build-service-builds

###########################################
# Kubernetes
###########################################
# Workload Management > Supervisor Clusters > Controle Plane Node Address
CONTROL_PLANE_IP=10.213.111.4

# Path to tanzu-tools files
TANZU_TOOLS_FILES_PATH="/mnt/workspaces/tanzu-tools"
# Path to k8s deployment files
TBS_FILES_PATH="$TANZU_TOOLS_FILES_PATH/tbs/"
# Path to tanzu-app
TANZU_APP_FILES_PATH="/mnt/workspaces/tanzu-app"