###########################################
# Azure
###########################################
RG_NAME=rg-tanzu-demo-12
CLUSTER_NAME=tanzu-demo-fmartin

###########################################
# TAP
###########################################
TAP_VERSION=1.2.0

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
export TAP_FILES_PATH="$TANZU_TOOLS_FILES_PATH/tap/"
# Path to app files
TANZU_APP_FILES_PATH="$WORKSPACE_FILES_PATH/tanzu-app"
#TANZU_APP_FILES_PATH="$WORKSPACE_FILES_PATH/tanzu-simple/tanzu-simple"
# Path to Petclinic
TANZU_PETCLINIC_FILES_PATH="$WORKSPACE_FILES_PATH/spring-petclinic-tanzu"

###########################################
# Imports
###########################################
source $TAP_FILES_PATH/00_pass.sh

export TAP_REGISTRY_HOSTNAME=fmartin.azurecr.io
export TAP_REGISTRY_USERNAME=$HARBOR_USER
export TAP_REGISTRY_PASSWORD=$HARBOR_PASS
