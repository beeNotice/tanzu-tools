# https://github.com/Tanzu-Solutions-Engineering/se-tap-bootcamps/tree/main/tap-up-and-running-bootcamp
# https://github.com/kennism/homelab/tree/main/tap

# Azure login
az login

# Set your default subscription
az account list --output table
az account set --subscription "subscription-id"
az account show --output table

# Preprare
# Add pod security policies support preview (required for learningcenter)
az extension add --name aks-preview
az feature register --name PodSecurityPolicyPreview --namespace Microsoft.ContainerService
# Wait until the status is "Registered"
az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/PodSecurityPolicyPreview')].{Name:name,State:properties.state}"
az provider register --namespace Microsoft.ContainerService

# Deploy
az group create --location francecentral --name ${RG_NAME}
az aks create --resource-group ${RG_NAME} --name ${CLUSTER_NAME} --node-count 3 --enable-addons monitoring --node-vm-size Standard_DS3_v2 --node-osdisk-size 500 --enable-pod-security-policy
az aks get-credentials --resource-group ${RG_NAME} --name ${CLUSTER_NAME}

# RBAC
kubectl create clusterrolebinding tap-psp-rolebinding --group=system:authenticated --clusterrole=psp:privileged

# Tanzu CLI
# https://network.tanzu.vmware.com/products/tanzu-application-platform/
# https://docs.vmware.com/en/Tanzu-Application-Platform/1.0/tap/GUID-install-tanzu-cli.html#cli-and-plugin
mkdir $HOME/tanzu
tar -xvf $TANZU_TOOLS_FILES_PATH/binaries/tanzu-framework-linux-1.0.2-amd64.tar -C $HOME/tanzu
export TANZU_CLI_NO_INIT=true
cd $HOME/tanzu
sudo install cli/core/v0.11.1/tanzu-core-linux_amd64 /usr/local/bin/tanzu
tanzu plugin install --local cli all

# Check
tanzu version
tanzu plugin list

# Cluste essentials
# https://docs.vmware.com/en/Tanzu-Application-Platform/1.0/tap/GUID-install-tanzu-cli.html#install-cluster-essentials-for-vmware-tanzu-3
mkdir $HOME/tanzu-cluster-essentials
tar -xvf $TANZU_TOOLS_FILES_PATH/binaries/tanzu-cluster-essentials-linux-amd64-1.0.0.tgz -C $HOME/tanzu-cluster-essentials

export INSTALL_REGISTRY_HOSTNAME=registry.tanzu.vmware.com
export INSTALL_REGISTRY_USERNAME=$TANZU_NET_USER
export INSTALL_REGISTRY_PASSWORD=$TANZU_NET_PASSWORD

# Add the Tanzu Application Platform package repository
export INSTALL_BUNDLE=registry.tanzu.vmware.com/tanzu-cluster-essentials/cluster-essentials-bundle@sha256:82dfaf70656b54dcba0d4def85ccae1578ff27054e7533d08320244af7fb0343
cd $HOME/tanzu-cluster-essentials
./install.sh
cd

sudo cp $HOME/tanzu-cluster-essentials/kapp /usr/local/bin/kapp
sudo cp $HOME/tanzu-cluster-essentials/imgpkg /usr/local/bin/imgpkg
sudo cp $HOME/tanzu-cluster-essentials/ytt /usr/local/bin/ytt

# Check
k get ns
kapp list -A

# Relocate image
# https://docs.vmware.com/en/Tanzu-Application-Platform/1.0/tap/GUID-install.html#relocate-images-to-a-registry-0
docker login -u fmartin@vmware.com registry.pivotal.io
docker login -u fmartin@vmware.com registry.tanzu.vmware.com
docker login -u fma harbor.withtanzu.com

imgpkg copy -b registry.tanzu.vmware.com/tanzu-application-platform/tap-packages:$TAP_VERSION --to-repo $INSTALL_REGISTRY_HOSTNAME/fmartin/tap-packages

# Install TAP
kubectl create ns tap-install

export INSTALL_REGISTRY_HOSTNAME=harbor.withtanzu.com
export INSTALL_REGISTRY_USERNAME=$HARBOR_USER
export INSTALL_REGISTRY_PASSWORD=$HARBOR_PASS

# Prepare Data
tanzu secret registry add tap-registry \
  --username ${INSTALL_REGISTRY_USERNAME} \
  --password ${INSTALL_REGISTRY_PASSWORD} \
  --server ${INSTALL_REGISTRY_HOSTNAME} \
  --export-to-all-namespaces \
  --yes \
  --namespace tap-install

tanzu package repository add tanzu-tap-repository \
  --url $INSTALL_REGISTRY_HOSTNAME/fmartin/tap-packages:$TAP_VERSION \
  --namespace tap-install

# Check
tanzu package repository get tanzu-tap-repository --namespace tap-install
tanzu package available list --namespace tap-install

# Deploy TAP
# https://docs.vmware.com/en/Tanzu-Application-Platform/1.0/tap/GUID-install.html#view-pkge-config-settings
# tanzu package available get tap.tanzu.vmware.com/$TAP_VERSION --values-schema --namespace tap-install
# tanzu package available get -n tap-install api-portal.tanzu.vmware.com/1.0.9 --values-schema
k create ns dev # Grype need the namespace to be provisioned before
tanzu package install tap \
     -p tap.tanzu.vmware.com \
     -v $TAP_VERSION \
     --values-file $TAP_FILES_PATH/data/tap-values-full.yml \
     -n tap-install

# Check
tanzu package installed list -A
kubectl describe PackageInstall <package-name> -n tap-install

# Set up developer namespaces to use installed packages
# https://docs.vmware.com/en/Tanzu-Application-Platform/1.0/tap/GUID-install-components.html#setup
# https://github.com/tsalm-pivotal/tap-install/blob/master/create-additional-dev-space.sh
$TAP_FILES_PATH/script/create-additional-dev-space.sh dev
# Add DB - see 02_deploy-postgres.sh

# Access Apps
kubectl get service envoy -n tanzu-system-ingress
# Create DNS entry to this IP or add it to the host C:\Windows\System32\drivers\etc
# Or create an A entry *.tanzu with the IP
http://tap-gui.tanzu.fmartin.tech/

# Check DNS
dig @8.8.8.8 tap-gui.tanzu.fmartin.tech

# Expose API Portal
# https://docs.vmware.com/en/API-portal-for-VMware-Tanzu/1.0/api-portal/GUID-configuring-k8s.html#configure-external-access
k apply -f $TAP_FILES_PATH/data/api-portal-httpproxy.yaml
k get httpproxy -A

# TAP GUI
# Create your application accelerator
# https://docs.vmware.com/en/Tanzu-Application-Platform/1.0/tap/GUID-getting-started.html#section-2-create-your-application-accelerator-10
# https://docs.vmware.com/en/Application-Accelerator-for-VMware-Tanzu/1.0/acc-docs/GUID-creating-accelerators-index.html
# http://tap-gui.fmartin.tech/create > New Accelerator > Follow README.yaml
# https://docs.vmware.com/en/Application-Accelerator-for-VMware-Tanzu/1.0/acc-docs/GUID-creating-accelerators-accelerator-yaml.html
kubectl apply -f $TAP_FILES_PATH/data/tanzu-app-accelerator/k8s-resource.yaml --namespace accelerator-system
k get Accelerator -n accelerator-system

tanzu accelerator list
# If you don't want to wait for 10 minutes after a Git update
tanzu accelerator update tanzu-app-demo -n accelerator-system --reconcile

# Add application to the Application Platform GUI Software Catalog
# https://docs.vmware.com/en/Tanzu-Application-Platform/1.0/tap/GUID-getting-started.html#add-your-application-to-tanzu-application-platform-gui-software-catalog-5
http://tap-gui.fmartin.tech/catalog > Register Entity
https://github.com/beeNotice/tanzu-app/blob/main/catalog-info.yaml


# TBS Configuration
# https://network.tanzu.vmware.com/products/tbs-dependencies#/releases/959846
kp clusterstack create old \
--build-image registry.pivotal.io/tanzu-base-bionic-stack/build@sha256:001c34f7f36227569e622424e64905dcc508a67486ebb1dc4aa73123e76982bc \
--run-image registry.pivotal.io/tanzu-base-bionic-stack/run@sha256:dc6a55b81d2f8adef4b8e509e1f3e182b2f7b1dafe4d0fdede8c4195c8c39de3

kp clusterstack list

# Modifying OpenAPI Source URL Locations
# https://docs.vmware.com/en/API-portal-for-VMware-Tanzu/1.0/api-portal/GUID-configuring-k8s.html#modifying-openapi-source-url-locations
kubectl set env deployment.apps/api-portal-server -n api-portal \
  API_PORTAL_SOURCE_URLS="https://petstore.swagger.io/v2/swagger.json,https://petstore3.swagger.io/api/v3/openapi.json,http://tanzu-app-deploy-dev.tanzu.fmartin.tech/v3/api-docs"

###########################################
# Day 2
###########################################
# Start / Stop AKS
az aks start --resource-group rg-tanzu-tap --name aks-tanzu-tap
az aks stop --resource-group rg-tanzu-tap --name aks-tanzu-tap

# Update tap
tanzu package installed update tap \
     -p tap.tanzu.vmware.com \
     -v $TAP_VERSION \
     --values-file $TAP_FILES_PATH/data/tap-values-full.yml \
     -n tap-install

# Update TBS
docker login -u fmartin@vmware.com registry.pivotal.io
docker login -u fmartin@vmware.com registry.tanzu.vmware.com
docker login -u fma harbor.withtanzu.com

kp import -f tap-descriptor-<version>.yaml