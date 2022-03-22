###########################################
# Jumpbox
###########################################
# Name of the user in the jumpbox VM
VM_USER=tanzu
# Folder to put cli binaries
BIN_FOLDER=/usr/local/bin/
# Path to tanzu-tools files
TANZU_TOOLS_FILES_PATH="/mnt/workspaces/tanzu-tools"
# Path to k8s deployment files
K8S_FILES_PATH="$TANZU_TOOLS_FILES_PATH/k8s/"

# https://github.com/vmware-tanzu/community-edition/releases/
TCE_RELEASE_VERSION=v0.10.0
TCE_RELEASE_OS_DISTRIBUTION=linux

# https://kubernetes.io/releases/
KUBECTL_VERSION=v1.21.7