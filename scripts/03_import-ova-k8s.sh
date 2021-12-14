#!/bin/bash
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-mgmt-clusters-vsphere.html#import-base

# Create Ressource Pool
govc pool.create $GOVC_RESOURCE_POOL

# Create VM Folder
govc folder.create /${GOVC_DATACENTER}/vm/${TKG_VM_DIR}

# Import OS image
govc import.spec ${OVA_FILE} | jq '.Name="'${OVA_NAME}'"' | jq '.NetworkMapping [0].Network="'"${GOVC_NETWORK}"'"' > ${OVA_NAME}.json
govc import.ova -options=${OVA_NAME}.json ${OVA_FILE}
rm ${OVA_NAME}.json
govc vm.markastemplate ${OVA_NAME}
govc object.mv /${GOVC_DATACENTER}/vm/${OVA_NAME} /${GOVC_DATACENTER}/vm/${TKG_VM_DIR}
