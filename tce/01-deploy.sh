# Azure VM
# https://learn.microsoft.com/en-us/azure/virtual-machines/linux/tutorial-manage-vm
az group create --name tce-fmartin --location francecentral

az vm create \
    --resource-group tce-fmartin \
    --name vm-tce-fmartin \
    --image Canonical:0001-com-ubuntu-server-focal:20_04-lts:20.04.202209200 \
    --admin-username fmartin \
    --size Standard_D3_v2 \
    --public-ip-sku Standard \
    --generate-ssh-keys

az vm auto-shutdown --resource-group tce-fmartin --name vm-tce-fmartin --time 2130

VM_IP=$(az vm list-ip-addresses --resource-group tce-fmartin --name vm-tce-fmartin --query "[].virtualMachine.network.publicIpAddresses[0].ipAddress" --output tsv)
ssh fmartin@$VM_IP

# Install CLI
sh $TANZU_TOOLS_FILES_PATH/tce/01_cli.sh

# Install Project
git clone https://github.com/beeNotice/tanzu-tools.git

# Deploy Cluster
tanzu unmanaged-cluster create tce-local -c calico -p 80:80 -p 443:443

# Navigate
k get nodes
kubectl get po -A

# Extensions
# https://tanzucommunityedition.io/docs/v0.11/package-management/#adding-a-package-repository
# Check repository
tanzu package repository list --all-namespaces
tanzu package available list

# Intstall packages
tanzu package install cert-manager \
   --package-name cert-manager.community.tanzu.vmware.com \
   --version ${CERT_MANAGER_PACKAGE_VERSION}

tanzu package install contour \
   --package-name contour.community.tanzu.vmware.com \
   --version ${CONTOUR_PACKAGE_VERSION} \
--values-file $TANZU_TCE_FILES_PATH/data/contour-values.yaml

tanzu package install kpack \
   --package-name kpack.community.tanzu.vmware.com \
   --version ${KPACK_PACKAGE_VERSION} \
--values-file kpack-values.yaml

# Check
tanzu package installed list --all-namespaces

# Deploy App
# Note : Allow the access on port 80 if you are on a Cloud Provider

_______________________________________________________________

# Delete Azure
az group delete --name tce-fmartin

