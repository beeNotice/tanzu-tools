#!/bin/bash
# https://github.com/laidbackware/vmd
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-mgmt-clusters-vsphere.html#import-base

# vmd get versions -p vmware_tanzu_kubernetes_grid -s tkg
# vmd get files -p vmware_tanzu_kubernetes_grid -s tkg -v 1.4.2
vmd download -p vmware_tanzu_kubernetes_grid -s tkg -v 1.4.2 -f $OVA_FILE --accepteula
cd ~/vmd-downloads/

# Create Ressource Pool
govc pool.create $GOVC_RESOURCE_POOL

# Create VM Folder
govc folder.create /${GOVC_DATACENTER}/vm/${TKG_VM_DIR}

# Import OS image
govc import.spec ${OVA_FILE} | jq '.Name="'${OVA_NAME}'"' | jq '.NetworkMapping [0].Network="'"${GOVC_NETWORK}"'"' > ${OVA_NAME}.json
govc import.ova -options=${OVA_NAME}.json ${OVA_FILE}

govc vm.markastemplate ${OVA_NAME}
govc object.mv /${GOVC_DATACENTER}/vm/${OVA_NAME} /${GOVC_DATACENTER}/vm/${TKG_VM_DIR}

# Restore state
rm ${OVA_NAME}.json
cd -
