###########################################
# Azure
###########################################
RG_NAME=rg-tanzu-demo
CLUSTER_NAME=aks-tanzu-fmartin

###########################################
# TAP
###########################################
TAP_VERSION=1.1.2

# Folder to put cli binaries
BIN_FOLDER=/usr/local/bin/

###########################################
# Deployment
###########################################
# Path to workspace folder
WORKSPACE_FILES_PATH="/mnt/c/Dev/workspaces"
#WORKSPACE_FILES_PATH="/mnt/workspaces"
# Path to tanzu-tools files
TANZU_TOOLS_FILES_PATH="$WORKSPACE_FILES_PATH/tanzu-tools/"
# Path to k8s deployment files
TAP_FILES_PATH="$TANZU_TOOLS_FILES_PATH/tap/"
# Path to app files
TANZU_APP_FILES_PATH="$WORKSPACE_FILES_PATH/tanzu-app"

TAP_DEV_NAMESPACE=dev

###########################################
# Imports
###########################################
source $TAP_FILES_PATH/00_pass.sh

export TAP_REGISTRY_HOSTNAME=harbor.withtanzu.com
export TAP_REGISTRY_USERNAME=$HARBOR_USER
export TAP_REGISTRY_PASSWORD=$HARBOR_PASS
