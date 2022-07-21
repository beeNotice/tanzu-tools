# https://docs.vmware.com/en/Service-Installer-for-VMware-Tanzu/1.2/service-installer/GUID-WhatsNew.html
# https://docs.vmware.com/en/Service-Installer-for-VMware-Tanzu/1.2/service-installer/GUID-vSphere%20-%20Backed%20by%20VDS-TKGs-TKOonVsphereVDStkgs.html

# Download Service Installer
https://marketplace.cloud.vmware.com/services/details/service-installer-for-vmware-tanzu-1?slug=true

# Upload to vCenter
OVA_NAME=service-installer-for-vmware-tanzu-1.3.0.59-20112357_ovf10
OVA_FILE=$OVA_NAME.ova
OVA_PATH=/home/ubuntu/$OVA_FILE

govc import.spec ${OVA_PATH} | jq '.Name="'${OVA_NAME}'"' | jq '.NetworkMapping [0].Network="'"${GOVC_NETWORK}"'"' > tkg-ova.json && \
    govc import.ova -options=tkg-ova.json ${OVA_PATH} && \
    govc vm.markastemplate ${OVA_NAME} && \
    rm tkg-ova.json

# New VM from this Template - Configure all
VM_IP=10.220.47.160
ssh root@$VM_IP

# Configure
http://$VM_IP:8888/#/ui

NOTE: Use the Gateway CIDR, not the vlan one

# Deploy
cat /opt/vmware/arcas/src/vsphere-dvs-tkgs-wcp.json
arcas --env vsphere --file /opt/vmware/arcas/src/vsphere-dvs-tkgs-wcp.json --avi_configuration --avi_wcp_configuration --enable_wcp --verbose

# Troubleshhoting
ssh -o PubkeyAuthentication=no root@$VM_IP
Use vCenter IP instead of FQDN
