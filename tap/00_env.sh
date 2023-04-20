###########################################
# Azure
###########################################
RG_NAME=rg-tanzu-demo-14
CLUSTER_NAME=tanzu-demo-fmartin

###########################################
# TAP
###########################################
TAP_VERSION=1.4.2

# Folder to put cli binaries
BIN_FOLDER=/usr/local/bin/

###########################################
# Deployment
###########################################
# Path to workspace folder
WORKSPACE_FILES_PATH="/mnt/c/Dev/workspaces"
# Path to tanzu-tools files
TANZU_TOOLS_FILES_PATH="$WORKSPACE_FILES_PATH/tanzu-tools/"
# Path to k8s deployment files
export TAP_FILES_PATH="$TANZU_TOOLS_FILES_PATH/tap/"
# Path to app files
TANZU_APP_FILES_PATH="$WORKSPACE_FILES_PATH/tanzu-simple"

###########################################
# Imports
###########################################
source $TAP_FILES_PATH/00_pass.sh

export TAP_REGISTRY_HOSTNAME=fmartin.azurecr.io
export TAP_REGISTRY_USERNAME=$REGISTRY_USER
export TAP_REGISTRY_PASSWORD=$REGISTRY_PASS
