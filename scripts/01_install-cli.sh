#!/bin/bash

###########################################
# Variables
###########################################

VM_USER=tanzu
BIN_FOLDER=/usr/local/bin/

# https://kubernetes.io/releases/
KUBECTL_VERSION=v1.21.7
# https://github.com/kubernetes-sigs/kind/releases
KIND_VERSION=v0.11.1

TKG_VERSION=v1.4.0


###########################################
# Script
###########################################

# Common
sudo apt-get update
sudo apt-get -y install curl jq unzip bash-completion dos2unix

# Kubernetes
# https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
curl -LO https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl
sudo mv kubectl $BIN_FOLDER
sudo chmod +x $BIN_FOLDER/kubectl

# Docker
# https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm get-docker.sh 
sudo adduser ${VM_USER} docker

# Kind
# https://kind.sigs.k8s.io/docs/user/quick-start/#installing-from-release-binaries
curl -Lo ./kind https://kind.sigs.k8s.io/dl/$KIND_VERSION/kind-linux-amd64
sudo mv kind $BIN_FOLDER
chmod +x $BIN_FOLDER/kind

# Carvel
curl -L https://carvel.dev/install.sh -o install-carvel.sh
sudo bash install-carvel.sh
rm install-carvel.sh

# VMware vSphere API
curl -LO  https://github.com/vmware/govmomi/releases/download/v0.23.0/govc_linux_amd64.gz
gunzip govc_linux_amd64.gz
sudo mv govc_linux_amd64 $BIN_FOLDER/govc
chmod +x $BIN_FOLDER/govc

# Tanzu
# https://my.vmware.com/en/web/vmware/downloads/info/slug/infrastructure_operations_management/vmware_tanzu_kubernetes_grid/1_x
cd ~
mkdir tanzu
tar xvf tanzu-cli-bundle-linux-amd64.tar -C tanzu 
cd ~/tanzu/cli 
sudo install core/$TKG_VERSION/tanzu-core-linux_amd64 $BIN_FOLDER/tanzu 
cd ~/tanzu
tanzu plugin clean
tanzu plugin install --local cli all 
tanzu plugin list
cd
