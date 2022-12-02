###########################################
# Jumpbox
###########################################
# Name of the user in the jumpbox VM
VM_USER=fmartin
# Folder to put cli binaries
BIN_FOLDER=/usr/local/bin/
# Path to tanzu-tools files
TANZU_TOOLS_FILES_PATH="/mnt/c/Dev/workspaces/tanzu-tools/"
# Path to k8s deployment files
K8S_FILES_PATH="$TANZU_TOOLS_FILES_PATH/k8s/"
# Path to TCE deployment files
TANZU_TCE_FILES_PATH="$TANZU_TOOLS_FILES_PATH/tce/"

# https://github.com/vmware-tanzu/community-edition/releases/
TCE_RELEASE_VERSION=v0.11.0
TCE_RELEASE_OS_DISTRIBUTION=linux
TCE_PACKAGE_VERSION=0.11.0

# https://kubernetes.io/releases/
KUBECTL_VERSION=v1.22.4

HARBOR_URL=harbor-fmartin-tanzu.francecentral.cloudapp.azure.com/fmartin/kpack

CLUSTER_NAME=tce-local

###########################################
# Package versions
###########################################
CERT_MANAGER_PACKAGE_VERSION="1.6.1"
CONTOUR_PACKAGE_VERSION="1.20.1"
HARBOR_PACKAGE_VERSION="2.3.3"
KPACK_PACKAGE_VERSION="0.5.1"