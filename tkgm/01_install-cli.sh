#!/bin/bash

# Common
sudo apt-get update
sudo apt-get -y install curl jq unzip bash-completion dos2unix bash-completion
sudo snap install yq
sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' .bashrc

# SSH Key
ssh-keygen -t rsa -b 4096

# vSphere SSL certificate
# https://kb.vmware.com/s/article/2108294


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

# Download software from customerconnect.vmware.com
# https://github.com/laidbackware/vmd
curl -LO  https://github.com/laidbackware/vmd/releases/download/v$VMD_VERSION/vmd-linux-v$VMD_VERSION
sudo mv vmd-linux-v$VMD_VERSION $BIN_FOLDER/vmd
chmod +x $BIN_FOLDER/vmd

# VMware vSphere API
curl -LO  https://github.com/vmware/govmomi/releases/download/v0.23.0/govc_linux_amd64.gz
gunzip govc_linux_amd64.gz
sudo mv govc_linux_amd64 $BIN_FOLDER/govc
chmod +x $BIN_FOLDER/govc

# Helm
curl -LO https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz
mkdir helm
tar -zxvf helm-v${HELM_VERSION}-linux-amd64.tar.gz -C helm
sudo mv helm/linux-amd64/helm $BIN_FOLDER/helm
rm -Rf helm
rm helm-v${HELM_VERSION}-linux-amd64.tar.gz

# Tanzu
# https://my.vmware.com/en/web/vmware/downloads/info/slug/infrastructure_operations_management/vmware_tanzu_kubernetes_grid/1_x
cd ~
mkdir tanzu
tar xvf $TANZU_TOOLS_FILES_PATH/binaries/tanzu-cli-bundle-linux-amd64.tar -C tanzu 
cd ~/tanzu/cli 
sudo install core/$TKG_VERSION/tanzu-core-linux_amd64 $BIN_FOLDER/tanzu 
cd ~/tanzu
tanzu plugin clean
tanzu plugin install --local cli all 
tanzu plugin list
cd

# Velero
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-cluster-lifecycle-backup-restore-mgmt-cluster.html#cli
# https://customerconnect.vmware.com/en/downloads/details?downloadGroup=TKG-140&productId=988&rPId=73652
gzip -d velero-linux-v1.6.2_vmware.1.gz
sudo mv velero-linux-v1.6.2_vmware.1 $BIN_FOLDER/velero
chmod +x $BIN_FOLDER/velero

# Minio
wget https://dl.min.io/client/mc/release/linux-amd64/mc
sudo mv mc $BIN_FOLDER/mc
chmod +x $BIN_FOLDER/mc

# kubectx & kubens
git clone https://github.com/ahmetb/kubectx
cd kubectx
sudo mv kubectx $BIN_FOLDER/kubectx
sudo mv kubens $BIN_FOLDER/kubens
sudo mv completion/*.bash $COMPLETIONS
cd
rm -rf kubectx

# Create completions & aliases
# https://kubernetes.io/docs/tasks/tools/included/optional-kubectl-configs-bash-linux/
sudo kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
sudo tanzu completion bash | sudo tee /etc/bash_completion.d/tanzu > /dev/null

echo 'alias k=kubectl' >>~/.bash_aliases
echo 'complete -F __start_kubectl k' >>~/.bash_aliases
echo 'alias kctx=kubectx' >>~/.bash_aliases
echo 'alias kns=kubens' >>~/.bash_aliases