###########################################
# Setup Cluster
###########################################
# Deploy
az group create --location francecentral --name ${RG_NAME}
az aks create --resource-group ${RG_NAME} --name ${CLUSTER_NAME} --node-count 3 --enable-addons monitoring --node-vm-size Standard_DS4_v2 --node-osdisk-size 500 --enable-pod-security-policy
az aks get-credentials --resource-group ${RG_NAME} --name ${CLUSTER_NAME}

# RBAC
kubectl create clusterrolebinding tap-psp-rolebinding --group=system:authenticated --clusterrole=psp:privileged

###########################################
# Prepare Github - SSH
###########################################
# https://docs.vmware.com/en/Tanzu-Application-Platform/1.3/tap/GUID-scc-ootb-supply-chain-basic.html#gitops
# https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.3/tap/GUID-scc-gitops-vs-regops.html
# https://vmware.slack.com/archives/C02D60T1ZDJ/p1639034875225700
ssh-keygen -t ed25519
ssh-keyscan github.com > $HOME/known_hosts

###########################################
# Tanzu CLI
###########################################
# https://network.tanzu.vmware.com/products/tanzu-application-platform/
# https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.3/tap/GUID-install-tanzu-cli.html
mkdir $HOME/tanzu
tar -xvf $TANZU_TOOLS_FILES_PATH/binaries/tanzu-framework-linux-amd64-v0.25.0.4.tar -C $HOME/tanzu
export TANZU_CLI_NO_INIT=true
cd $HOME/tanzu
export VERSION=v0.25.0
sudo install cli/core/$VERSION/tanzu-core-linux_amd64 /usr/local/bin/tanzu
tanzu plugin install --local cli all
cd

# Check
tanzu version
tanzu plugin list

###########################################
# Cluster essentials
###########################################
# https://docs.vmware.com/en/Cluster-Essentials-for-VMware-Tanzu/1.3/cluster-essentials/GUID-deploy.html
mkdir $HOME/tanzu-cluster-essentials
tar -xvf $TANZU_TOOLS_FILES_PATH/binaries/tanzu-cluster-essentials-linux-amd64-1.3.0.tgz -C $HOME/tanzu-cluster-essentials

# Credentials for VMware Tanzu Network.
export INSTALL_REGISTRY_HOSTNAME=registry.tanzu.vmware.com
export INSTALL_REGISTRY_USERNAME=$TANZU_NET_USER
export INSTALL_REGISTRY_PASSWORD=$TANZU_NET_PASSWORD

# Add the Tanzu Application Platform package repository
export INSTALL_BUNDLE=registry.tanzu.vmware.com/tanzu-cluster-essentials/cluster-essentials-bundle@sha256:54bf611711923dccd7c7f10603c846782b90644d48f1cb570b43a082d18e23b9
cd $HOME/tanzu-cluster-essentials
./install.sh --yes
cd

sudo cp $HOME/tanzu-cluster-essentials/kapp /usr/local/bin/kapp
sudo cp $HOME/tanzu-cluster-essentials/imgpkg /usr/local/bin/imgpkg
sudo cp $HOME/tanzu-cluster-essentials/ytt /usr/local/bin/ytt

# Check
k get ns
kapp list -A

###########################################
# Image relocation
###########################################
# DO IT FROM A MACHINE WITH A GOOD NETWORK
# Relocate image
# https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.3/tap/GUID-install.html
docker login -u fmartin@vmware.com registry.tanzu.vmware.com
docker login -u fmartin fmartin.azurecr.io

export INSTALL_REGISTRY_HOSTNAME=fmartin.azurecr.io
export INSTALL_REGISTRY_USERNAME=$REGISTRY_USER
export INSTALL_REGISTRY_PASSWORD=$REGISTRY_PASS
export TAP_VERSION=$TAP_VERSION
export INSTALL_REPO=fmartin

imgpkg copy -b registry.tanzu.vmware.com/tanzu-application-platform/tap-packages:${TAP_VERSION} --to-repo ${INSTALL_REGISTRY_HOSTNAME}/${INSTALL_REPO}/tap-packages

###########################################
# Install TAP
###########################################
# https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.3/tap/GUID-install.html#add-the-tanzu-application-platform-package-repository-1
kubectl create ns tap-install

# Create a registry secret
tanzu secret registry add tap-registry \
  --username ${INSTALL_REGISTRY_USERNAME} \
  --password ${INSTALL_REGISTRY_PASSWORD} \
  --server ${INSTALL_REGISTRY_HOSTNAME} \
  --export-to-all-namespaces \
  --yes \
  --namespace tap-install

# Add the Tanzu Application Platform package repository to the cluster
tanzu package repository add tanzu-tap-repository \
  --url ${INSTALL_REGISTRY_HOSTNAME}/${INSTALL_REPO}/tap-packages:$TAP_VERSION \
  --namespace tap-install

# Check
tanzu package repository get tanzu-tap-repository --namespace tap-install
tanzu package available list --namespace tap-install

###########################################
# Deploy TAP
###########################################
# https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.3/tap/GUID-install.html#add-the-tanzu-application-platform-package-repository-1
# tanzu package available get tap.tanzu.vmware.com/$TAP_VERSION --values-schema --namespace tap-install
# tanzu package available get -n tap-install api-portal.tanzu.vmware.com/1.0.9 --values-schema
# tanzu package available get -n tap-install ootb-supply-chain-testing-scanning.tanzu.vmware.com/0.10.5 --values-schema
k create ns dev # Grype need the namespace to be provisioned before
tanzu package install tap \
     -p tap.tanzu.vmware.com \
     -v $TAP_VERSION \
     --values-file $TAP_FILES_PATH/data/tap-values-full.yml \
     -n tap-install

# Check
tanzu package installed get tap -n tap-install
tanzu package installed list -A
kubectl describe PackageInstall <package-name> -n tap-install

# Set up developer namespaces to use installed packages
# https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.3/tap/GUID-set-up-namespaces.html
# https://github.com/tsalm-pivotal/tap-install/blob/master/create-additional-dev-space.sh
sh $TAP_FILES_PATH/script/create-additional-dev-space.sh dev
sh $TAP_FILES_PATH/script/create-additional-dev-space.sh prod

# Access Apps
kubectl get service envoy -n tanzu-system-ingress
# Create DNS entry to this IP or add it to the host C:\Windows\System32\drivers\etc
# Or create an A entry *.tanzu with the IP

# Check DNS
dig @8.8.8.8 tap-gui.tanzu.beenotice.eu

# Access TAP
http://tap-gui.tanzu.beenotice.eu/

###########################################
# API Portal & Documentation
###########################################
# Expose 
# https://docs.vmware.com/en/API-portal-for-VMware-Tanzu/1.2/api-portal/GUID-configuring-k8s-basics.html#configure-external-access
k apply -f $TAP_FILES_PATH/data/api-portal-ingress.yaml
k get ingress -A

###########################################
# Test Workload
###########################################
tanzu apps workload create -f $TAP_FILES_PATH/data/workload.yaml -y
tanzu apps workload delete -f $TAP_FILES_PATH/data/workload.yaml -y

###########################################
# Next steps
###########################################
# Continue to 03_supply-chain-install.sh

###########################################
# TBS Configuration
###########################################
# https://network.tanzu.vmware.com/products/tbs-dependencies#/releases/959846
# Same credentials as Tanzu Net
docker login -u fmartin@vmware.com registry.pivotal.io
kp clusterstack create old \
--build-image registry.pivotal.io/tanzu-base-bionic-stack/build@sha256:7f4777ef6f9bfc01a884ae81ecc5fb4a2eeba5c28b59c2b94666a4e5e35f8d4c \
--run-image registry.pivotal.io/tanzu-base-bionic-stack/run@sha256:87d92d68b7f5c4c22da6985947e585dc95346898adf82c2c3708dd0ef7a9bef3

kp clusterstack list
kp clusterbuilder patch default --stack old

wget https://raw.githubusercontent.com/beeNotice/tanzu-simple/main/config/workload.yaml
tanzu apps workload create -f workload.yaml -y

# see 07_demo.sh

