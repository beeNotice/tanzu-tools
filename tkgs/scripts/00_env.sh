###########################################
# vSphere
###########################################
export GOVC_URL="vcsa.cpod-tanzu.az-fkd.cloud-garage.net"
export GOVC_USERNAME="administrator@cpod-tanzu.az-fkd.cloud-garage.net"
export GOVC_PASSWORD=""
export GOVC_DATACENTER="Datacenter"
export GOVC_NETWORK="Extra"
export GOVC_DATASTORE="LUN01"
export GOVC_RESOURCE_POOL="/$GOVC_DATACENTER/host/Cluster/Resources/AVI"
export GOVC_INSECURE=1
export KUBECTL_VSPHERE_PASSWORD=$GOVC_PASSWORD

###########################################
# Jumpbox
###########################################
# Name of the user in the jumpbox VM
VM_USER=tanzu
# Folder to put cli binaries
BIN_FOLDER=/usr/local/bin/
# Retrieve link from the vSphere Cluster > Namespaces > Summary > Link to CLI Tools
KUBECTL_LINK=https://10.213.199.3/wcp/plugin/linux-amd64/vsphere-plugin.zip
# https://github.com/helm/helm/releases
HELM_VERSION=3.7.2

###########################################
# AVI
###########################################
AVI_VM_DIR=AVI
OVA_AVI_NAME=controller-20.1.7-9154
OVA_AVI_FILE=${OVA_AVI_NAME}.ova
OVA_AVI_SPEC=${OVA_AVI_NAME}.json

# Management IP
ALB_CONTROLLER_IP=10.213.110.6
ALB_CONTROLLER_MASK=255.255.255.0
ALB_CONTROLLER_GW=10.213.110.1
ALB_CONTROLLER_NAME=avi
# In Pez VM Network is the Management one / Management is the name in VDS
ALB_CONTROLLER_NETWORK="Management"
ALB_SSH_KEY="$(cat ~/.ssh/id_rsa.pub)"


###########################################
# Kubernetes
###########################################
# Workload Management > Supervisor Clusters > Controle Plane Node Address
CONTROL_PLANE_IP=10.26.1.13

# Path to tanzu-tools files
TANZU_TOOLS_FILES_PATH="/mnt/workspaces/tanzu-tools"
#TANZU_TOOLS_FILES_PATH="/mnt/c/Dev/workspaces/tanzu-tools"
# Path to k8s deployment files
K8S_FILES_PATH="$TANZU_TOOLS_FILES_PATH/k8s/"

###########################################
# Imports
###########################################
source $TANZU_TOOLS_FILES_PATH/tkgs/scripts/00_pass.sh