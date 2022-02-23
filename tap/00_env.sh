###########################################
# TAP
###########################################
TAP_VERSION=1.0.0

# Folder to put cli binaries
BIN_FOLDER=/usr/local/bin/

###########################################
# Deployment
###########################################
# Path to tanzu-tools files
TANZU_TOOLS_FILES_PATH="/mnt/c/Dev/workspaces/tanzu-tools/"
# Path to k8s deployment files
TAP_FILES_PATH="$TANZU_TOOLS_FILES_PATH/tap/"
# Path to app files
TANZU_APP_FILES_PATH="/mnt/c/Dev/workspaces/tanzu-app"


###########################################
# Imports
###########################################
source $TAP_FILES_PATH/00_pass.sh

#TANZU_NET_USER=
#TANZU_NET_PASSWORD=
#HARBOR_USER=
#HARBOR_PASS=
#DOCKER_USER=
#DOCKER_PASS=