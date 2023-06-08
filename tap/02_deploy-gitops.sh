###########################################
# Setup Cluster AKS
###########################################
# Deploy
az group create --location francecentral --name ${RG_NAME}
az aks create --resource-group ${RG_NAME} --name ${CLUSTER_NAME} --node-count 3 --enable-addons monitoring --node-vm-size Standard_DS4_v2 --node-osdisk-size 500
az aks get-credentials --resource-group ${RG_NAME} --name ${CLUSTER_NAME}

###########################################
# Setup Cluster GKE
###########################################
# https://cloud.google.com/binary-authorization/docs/getting-started-cli
# https://cloud.google.com/compute/docs/general-purpose-machines?hl=fr
REGION=europe-west9
CLUSTER_ZONE="$REGION-a"
CLUSTER_NAME=gke-tanzu-demo-fmartin

gcloud container clusters create $CLUSTER_NAME \
    --binauthz-evaluation-mode=PROJECT_SINGLETON_POLICY_ENFORCE \
    --region $COMPUTE_REGION \
    --node-locations $COMPUTE_ZONE \
    --machine-type "e2-standard-8" \
    --num-nodes "3"
  
gcloud container clusters get-credentials \
    --region $COMPUTE_REGION \
    $CLUSTER_NAME

###########################################
# Deploy
###########################################
# https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.5/tap/install-gitops-intro.html
# https://vrabbi.cloud/post/tap-1-5-whats-new/

###########################################
# Tanzu CLI
###########################################
# https://network.tanzu.vmware.com/products/tanzu-application-platform
# https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.5/tap/install-tanzu-cli.html
mkdir $HOME/tanzu
tar -xvf $TANZU_TOOLS_FILES_PATH/binaries/tanzu-framework-linux-amd64-v0.28.1.1.tar -C $HOME/tanzu
export TANZU_CLI_NO_INIT=true
cd $HOME/tanzu
export VERSION=v0.28.1
sudo install cli/core/$VERSION/tanzu-core-linux_amd64 /usr/local/bin/tanzu
tanzu completion bash | sudo tee /etc/bash_completion.d/tanzu > /dev/null
cd

# Check
tanzu version

# Plugins
tanzu plugin install --local cli all
tanzu plugin list

###########################################
# Cluster essentials
###########################################
# https://docs.vmware.com/en/Cluster-Essentials-for-VMware-Tanzu/1.5/cluster-essentials/deploy.html
mkdir $HOME/tanzu-cluster-essentials
tar -xvf $TANZU_TOOLS_FILES_PATH/binaries/tanzu-cluster-essentials-linux-amd64-1.5.0.tgz -C $HOME/tanzu-cluster-essentials

kubectl create namespace kapp-controller

# Credentials for VMware Tanzu Network.
export INSTALL_BUNDLE=registry.tanzu.vmware.com/tanzu-cluster-essentials/cluster-essentials-bundle@sha256:79abddbc3b49b44fc368fede0dab93c266ff7c1fe305e2d555ed52d00361b446
export INSTALL_REGISTRY_HOSTNAME=registry.tanzu.vmware.com
export INSTALL_REGISTRY_USERNAME=$TANZU_NET_USER
export INSTALL_REGISTRY_PASSWORD=$TANZU_NET_PASSWORD

# Check if it needs a custom CA, if so follow the doc
# https://docs.vmware.com/en/Cluster-Essentials-for-VMware-Tanzu/1.3/cluster-essentials/GUID-deploy.html#deploy-onto-cluster-5

# Add the Tanzu Application Platform package repository

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
# DO IT FROM A MACHINE WITH A GOOD NETWORK - About 9 GiB to upload
# Relocate image
# https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.5/tap/install-gitops-sops.html#relocate-images-to-a-registry-1
docker login -u fmartin@vmware.com registry.tanzu.vmware.com
docker login -u fmartin fmartin.azurecr.io

export INSTALL_REGISTRY_HOSTNAME=fmartin.azurecr.io
export INSTALL_REGISTRY_USERNAME=$REGISTRY_USER
export INSTALL_REGISTRY_PASSWORD=$REGISTRY_PASS
export TAP_VERSION=$TAP_VERSION
export INSTALL_REPO=fmartin

imgpkg copy -b registry.tanzu.vmware.com/tanzu-application-platform/tap-packages:${TAP_VERSION} --to-repo ${INSTALL_REGISTRY_HOSTNAME}/${INSTALL_REPO}/tap-packages

###########################################
# Git Initialization
###########################################
# https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.5/tap/install-gitops-sops.html
# Create a new Git repository - https://github.com/beeNotice/tap-gitops

tar xvf $TANZU_TOOLS_FILES_PATH/binaries/tanzu-gitops-ri-0.1.0.tgz -C $TAP_GITOPS_FILES_PATH

# Push to Git
cd $TAP_GITOPS_FILES_PATH
git add . && git commit -m "Initialize Tanzu GitOps RI"
git push -u origin main

./setup-repo.sh $CLUSTER_NAME sops
git add . && git commit -m "Add $CLUSTER_NAME"
git push -u origin

###########################################
# Configuration
###########################################
# https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.5/tap/install-gitops-sops.html#preparing-sensitive-tanzu-application-platform-values-6

# Generate Age public or secrets keys
mkdir -p $HOME/tmp-enc
chmod 700 $HOME/tmp-enc
cd $HOME/tmp-enc

age-keygen -o key.txt
export SOPS_AGE_RECIPIENTS=$(cat key.txt | grep "# public key: " | sed 's/# public key: //')
cd -

# Encrypt file
sops --encrypt $TAP_FILES_PATH/data/tap-sensitive-values.yaml > $TAP_FILES_PATH/data/tap-sensitive-values.sops.yaml

# Decrypt file
export SOPS_AGE_KEY_FILE=$HOME/tmp-enc/key.txt
sops --decrypt $TAP_FILES_PATH/data/tap-sensitive-values.sops.yaml

# Copy files to Git
cp $TAP_FILES_PATH/data/tap-sensitive-values.sops.yaml $TAP_GITOPS_FILES_PATH/clusters/$CLUSTER_NAME/cluster-config/values/
cp $TAP_FILES_PATH/data/tap-non-sensitive-values.yaml $TAP_GITOPS_FILES_PATH/clusters/$CLUSTER_NAME/cluster-config/values/

export GIT_SSH_PRIVATE_KEY=$(cat $HOME/.ssh/id_ed25519)
export GIT_KNOWN_HOSTS=$(ssh-keyscan github.com)
export SOPS_AGE_KEY=$(cat $HOME/tmp-enc/key.txt)
export TAP_PKGR_REPO=${INSTALL_REGISTRY_HOSTNAME}/${INSTALL_REPO}/tap-packages

# Generate configuration file
cd $TAP_GITOPS_FILES_PATH/clusters/$CLUSTER_NAME
./tanzu-sync/scripts/configure.sh

git add .
git commit -m "Configure install of TAP $TAP_VERSION"
git push

###########################################
# General configuration
###########################################

kubectl create namespace tap-install

# Git secret
# https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.5/tap/namespace-provisioner-customize-installation.html#git-import-user
# https://vmware.slack.com/archives/C02D60T1ZDJ/p1682367234403699
# https://vmware.slack.com/archives/C02D60T1ZDJ/p1686000062935879?thread_ts=1685683898.379399&cid=C02D60T1ZDJ
kubectl create secret generic git-ssh \
--from-file=ssh-privatekey=$HOME/.ssh/id_ed25519 \
--from-file=identity=$HOME/.ssh/id_ed25519 \
--from-file=identity.pub=$HOME/.ssh/id_ed25519.pub \
--from-file=known_hosts=$HOME/known_hosts \
--type=kubernetes.io/ssh-auth \
-n tap-install
kubectl annotate secret git-ssh tekton.dev/git-0='github.com' -n tap-install

k get secret git-ssh -n tap-install -o yaml > $TAP_FILES_PATH/data/github-secret.yaml
sops --encrypt $TAP_FILES_PATH/data/github-secret.yaml > $TAP_FILES_PATH/data/github-secret.sops.yaml
cp $TAP_FILES_PATH/data/github-secret.sops.yaml $TAP_GITOPS_FILES_PATH/clusters/$CLUSTER_NAME/cluster-config/config/custom/

export SOPS_AGE_KEY_FILE=$HOME/tmp-enc/key.txt
sops --decrypt $TAP_GITOPS_FILES_PATH/clusters/$CLUSTER_NAME/cluster-config/config/custom/github-secret.sops.yaml

###########################################
# Deployment
###########################################
# https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.5/tap/install-gitops-sops.html#deploy-tanzu-sync-10
cd $TAP_GITOPS_FILES_PATH/clusters/$CLUSTER_NAME
./tanzu-sync/scripts/deploy.sh

# Check
kapp inspect -a tanzu-sync
tanzu package installed list -A
kubectl describe PackageInstall <package-name> -n tap-install
# kubectl describe PackageInstall contour -n tap-install

# k9s 
: pkgi

###########################################
# Deployment
###########################################
kubectl get service envoy -n tanzu-system-ingress
# Create DNS entry to this IP or add it to the host C:\Windows\System32\drivers\etc
# Or create an A entry *.tanzu with the IP

# Check DNS
dig @8.8.8.8 tap-gui.tanzu.beenotice.eu

# Check Proxy
k get HttpProxy -A

# Access TAP
ENVOY_IP=$(kubectl get services envoy -n tanzu-system-ingress --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl -H "host: tap-gui.tanzu.beenotice.eu" $ENVOY_IP
https://tap-gui.tanzu.beenotice.eu/


###########################################
# Install individual packages
###########################################
# Continue to 03_supply-chain-install.sh

###########################################
# Checks
###########################################
kubectl get pipeline.tekton.dev,scanpolicies -n dev