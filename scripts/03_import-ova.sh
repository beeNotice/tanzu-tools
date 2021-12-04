#!/bin/bash
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-mgmt-clusters-vsphere.html#import-base

###########################################
# Variables
###########################################

export GOVC_DATACENTER="Datacenter"
export GOVC_USERNAME="administrator@vsphere.local"
export GOVC_PASSWORD="M8bZ0lzQB1nlswl3NA!"
export GOVC_URL="vcsa-01.haas-489.pez.vmware.com"
export GOVC_INSECURE=1
export GOVC_NETWORK="VM Network"

# Photon v3 Kubernetes v1.21.2 OVA
TKG_DIR="TKG"
OVA_NAME=photon-3-kube-v1.21.2+vmware.1-tkg.2-12816990095845873721
OVA_FILE=${OVA_NAME}.ova


###########################################
# Script
###########################################

# Create VM Folder
govc folder.create /${GOVC_DATACENTER}/vm/${TKG_DIR}

# Import image
govc import.spec ${OVA_FILE} | jq '.Name="'${OVA_NAME}'"' | jq '.NetworkMapping [0].Network="'"${GOVC_NETWORK}"'"' > ${OVA_NAME}.json
govc import.ova -options=${OVA_NAME}.json ${OVA_FILE}
rm ${OVA_NAME}.json
govc vm.markastemplate ${OVA_NAME}
