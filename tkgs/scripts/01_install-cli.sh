#!/bin/bash

# vSphere SSL certificate
# https://kb.vmware.com/s/article/2108294


# Kubernetes
# https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
# Retrieve link from the vCenter Namespace
curl -LO $KUBECTL_LINK --insecure
unzip vsphere-plugin.zip -d vsphere-plugin
chmod +x vsphere-plugin/bin/*
sudo mv vsphere-plugin/bin/* $BIN_FOLDER
rm -Rf vsphere-plugin
rm vsphere-plugin.zip

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

echo 'alias k=kubectl' >>~/.bash_aliases
echo 'complete -F __start_kubectl k' >>~/.bash_aliases
echo 'alias kctx=kubectx' >>~/.bash_aliases
echo 'alias kns=kubens' >>~/.bash_aliases