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
# https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.4/tap/install-tanzu-cli.html
mkdir $HOME/tanzu
tar -xvf $TANZU_TOOLS_FILES_PATH/binaries/tanzu-framework-linux-amd64-v0.25.4.5.tar -C $HOME/tanzu
export TANZU_CLI_NO_INIT=true
cd $HOME/tanzu
export VERSION=v0.25.4
sudo install cli/core/$VERSION/tanzu-core-linux_amd64 /usr/local/bin/tanzu
tanzu plugin install --local cli all
cd

# Check
tanzu version
tanzu plugin list

###########################################
# Cluster essentials
###########################################
# https://docs.vmware.com/en/Cluster-Essentials-for-VMware-Tanzu/1.4/cluster-essentials/deploy.html
mkdir $HOME/tanzu-cluster-essentials
tar -xvf $TANZU_TOOLS_FILES_PATH/binaries/tanzu-cluster-essentials-linux-amd64-1.4.1.tgz -C $HOME/tanzu-cluster-essentials

# Credentials for VMware Tanzu Network.
export INSTALL_REGISTRY_HOSTNAME=registry.tanzu.vmware.com
export INSTALL_REGISTRY_USERNAME=$TANZU_NET_USER
export INSTALL_REGISTRY_PASSWORD=$TANZU_NET_PASSWORD

# Check if it needs a custom CA, if so follow the doc
# https://docs.vmware.com/en/Cluster-Essentials-for-VMware-Tanzu/1.3/cluster-essentials/GUID-deploy.html#deploy-onto-cluster-5

# Add the Tanzu Application Platform package repository
export INSTALL_BUNDLE=registry.tanzu.vmware.com/tanzu-cluster-essentials/cluster-essentials-bundle@sha256:2354688e46d4bb4060f74fca069513c9b42ffa17a0a6d5b0dbb81ed52242ea44
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
# https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.4/tap/install.html
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
# https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.4/tap/install.html#add-the-tanzu-application-platform-package-repository-1
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
tanzu package repository list -A
tanzu package repository get tanzu-tap-repository --namespace tap-install
tanzu package available list --namespace tap-install


# Patch to configure Accelerators Timeout
# https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.4/tap/application-accelerator-configuration.html
k apply -f $TAP_FILES_PATH/data/patch-accelerator-timeout.yaml

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
# kubectl describe PackageInstall fluxcd-source-controller -n tap-install

#################################################
# Developer namespaces - New WIP do not use yet
#################################################
# Set up developer namespaces to use installed packages
# https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.4/tap/set-up-namespaces.html
kubectl label namespaces dev apps.tanzu.vmware.com/tap-ns=""

tanzu secret registry add tbs-registry-credentials \
--server $TAP_REGISTRY_HOSTNAME \
--username $TAP_REGISTRY_USERNAME \
--password $TAP_REGISTRY_PASSWORD \
--export-to-all-namespaces --yes \
--namespace tap-install

# Check
kubectl get secrets,serviceaccount,rolebinding,pods,workload,configmap -n dev

#################################################
# Developer namespaces
#################################################
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
https://tap-gui.tanzu.beenotice.eu/

###########################################
# API Portal
###########################################
# Expose 
# https://docs.vmware.com/en/API-portal-for-VMware-Tanzu/1.2/api-portal/GUID-configuring-k8s-basics.html#configure-external-access
k apply -f $TAP_FILES_PATH/data/api-portal-ingress.yaml
k get ingress -A

###########################################
# API Auto registration
###########################################
# https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.4/tap/api-auto-registration-usage.html
# Nothing to do here, rely on the workload strategy

###########################################
# Custom Accelerator
###########################################
k apply -f $TAP_FILES_PATH/data/patch-accelerator-timeout.yaml

# https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.4/tap/application-accelerator-creating-accelerators-creating-accelerators.html
tanzu accelerator create tanzu-simple --git-repository https://github.com/beeNotice/tanzu-simple --git-branch main
# Check
tanzu accelerator list

# https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.4/tap/tap-gui-plugins-application-accelerator-git-repo.html


###########################################
# Test Workload
###########################################
tanzu apps workload create -f $TAP_FILES_PATH/data/workload.yaml -y
tanzu apps workload delete -f $TAP_FILES_PATH/data/workload.yaml -y

###########################################
# Supply Chain
###########################################
# Continue to 03_supply-chain-install.sh

###########################################
# TBS Configuration
###########################################
# https://network.tanzu.vmware.com/products/tbs-dependencies#/releases/959846
# Same credentials as Tanzu Net
docker login -u fmartin@vmware.com registry.pivotal.io
kp clusterstack create old \
--build-image registry.pivotal.io/tanzu-base-bionic-stack/build@sha256:63ac574296e1a2032e3a14f7a2a351e771b32de10772cbb699e9f8b38442142f \
--run-image registry.pivotal.io/tanzu-base-bionic-stack/run@sha256:9f4bde6e96bae86246f725d6e76ea39ad460b50356c29869794b642908d641c4

kp clusterstack list
kp clusterbuilder patch default --stack old

wget https://raw.githubusercontent.com/beeNotice/tanzu-simple/main/config/workload.yaml
tanzu apps workload create -f workload.yaml -y

kp clusterbuilder patch default --stack new

###########################################
# Promotion
###########################################
wget https://raw.githubusercontent.com/beeNotice/tanzu-simple/main/config/deliverable.yaml
k apply -f deliverable.yaml

