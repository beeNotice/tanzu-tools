###########################################
# vSphere
###########################################
export GOVC_URL="vcsa-01.haas-489.pez.vmware.com"
export GOVC_USERNAME="administrator@vsphere.local"
export GOVC_PASSWORD=""
export GOVC_DATACENTER="Datacenter"
export GOVC_NETWORK="Extra"
export GOVC_DATASTORE="LUN01"
export GOVC_RESOURCE_POOL="/$GOVC_DATACENTER/host/Cluster/Resources/TKG"
export GOVC_INSECURE=1

###########################################
# Jumpbox
###########################################
# Name of the user in the jumpbox VM
VM_USER=fmartin
# Folder to put cli binaries
BIN_FOLDER=/usr/local/bin/
# https://kubernetes.io/releases/
KUBECTL_VERSION=v1.21.9
# https://github.com/kubernetes-sigs/kind/releases
KIND_VERSION=v0.11.1
# https://github.com/helm/helm/releases
HELM_VERSION=3.7.2
# TKG version
TKG_VERSION=v1.4.2
# Path to save completions
COMPLETIONS=/etc/bash_completion.d
# https://github.com/laidbackware/vmd/releases
VMD_VERSION=0.3.0

###########################################
# OVAs
###########################################
export VMD_USER=fmartin@vmware.com
export VMD_PASS=xxx

# Photon v3 Kubernetes v1.21.2 OVA
TKG_VM_DIR="TKG"
OVA_NAME=photon-3-kube-v1.21.2+vmware.1-tkg.2-12816990095845873721
OVA_FILE=${OVA_NAME}.ova

# AVI
AVI_VM_DIR=AVI
OVA_AVI_NAME=controller-20.1.6-9132
OVA_AVI_FILE=${OVA_AVI_NAME}.ova
OVA_AVI_SPEC=${OVA_AVI_NAME}.json

# Management IP
ALB_CONTROLLER_IP=10.213.136.20
ALB_CONTROLLER_MASK=255.255.255.0
ALB_CONTROLLER_GW=10.213.136.1
ALB_CONTROLLER_NAME=controller
# In Pez VM Network is the Management one
ALB_CONTROLLER_NETWORK="VM Network"
ALB_SSH_KEY="$(cat ~/.ssh/id_rsa.pub)"


###########################################
# Docker (used to perform deployment tests)
###########################################
DOCKER_REGISTRY_SERVER="https://index.docker.io/v1/"
DOCKER_USER="beenotice"
DOCKER_PASSWORD=""
DOCKER_EMAIL=""

###########################################
# Deployment
###########################################
# Path to tanzu-tools files
#TANZU_TOOLS_FILES_PATH="/mnt/workspaces/tanzu-tools"
TANZU_TOOLS_FILES_PATH="/mnt/c/Dev/workspaces/tanzu-tools"
# Path to k8s deployment files
K8S_FILES_PATH="$TANZU_TOOLS_FILES_PATH/k8s/"
# Namespace to deploy tanzu package
USER_PACKAGE_NAMESPACE="tanzu-user-managed-packages"

# Harbor
# kubectl get httpproxy -A in the shared cluster
HARBOR_URL=harbor.haas-489.pez.vmware.com
NOTARY_URL=notary.harbor.haas-489.pez.vmware.com

GRAFANA_VERSION="7.5.7+vmware.1-tkg.1"
PROMETHEUS_VERSION="2.27.0+vmware.1-tkg.1"
CONTOUR_VERSION="1.17.1+vmware.1-tkg.1"
CERT_MANAGER_VERSION="1.1.0+vmware.1-tkg.2"
FLUENT_BIT_VERSION="1.7.5+vmware.1-tkg.1"
HARBOR_VERSION="2.2.3+vmware.1-tkg.1"
