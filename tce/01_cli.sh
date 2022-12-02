#!/bin/bash

. 00_env.sh

# Common
sudo apt-get update
sudo apt-get -y install curl grep sed jq unzip bash-completion dos2unix bash-completion
sudo snap install yq
sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' .bashrc
source .bashrc

# Docker
# https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm get-docker.sh 
sudo adduser ${VM_USER} docker

# Reload current user
exec su -l $VM_USER

# Carvel
curl -L https://carvel.dev/install.sh -o install-carvel.sh
sudo bash install-carvel.sh
rm install-carvel.sh

# Kubernetes
# https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
curl -LO https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl
sudo mv kubectl $BIN_FOLDER
sudo chmod +x $BIN_FOLDER/kubectl

# KP
# https://github.com/vmware-tanzu/kpack-cli/releases
wget -O kp "https://github.com/vmware-tanzu/kpack-cli/releases/download/v0.4.2/kp-linux-0.4.2"
sudo mv kp $BIN_FOLDER/kp
sudo chmod +x $BIN_FOLDER/kp

# kubectx & kubens
git clone https://github.com/ahmetb/kubectx
cd kubectx
sudo mv kubectx $BIN_FOLDER/kubectx
sudo mv kubens $BIN_FOLDER/kubens
sudo mv completion/*.bash $COMPLETIONS
cd
rm -rf kubectx

# Install Tanzu & TCE
curl -H "Accept: application/vnd.github.v3.raw" \
    -L https://api.github.com/repos/vmware-tanzu/community-edition/contents/hack/get-tce-release.sh | \
    bash -s $TCE_RELEASE_VERSION $TCE_RELEASE_OS_DISTRIBUTION
tar xzvf tce-linux-amd64-$TCE_RELEASE_VERSION.tar.gz
cd tce-linux-amd64-$TCE_RELEASE_VERSION
./install.sh
cd -

# Create completions & aliases
# https://kubernetes.io/docs/tasks/tools/included/optional-kubectl-configs-bash-linux/
sudo kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
sudo tanzu completion bash | sudo tee /etc/bash_completion.d/tanzu > /dev/null

echo 'alias k=kubectl' >>~/.bash_aliases
echo 'complete -F __start_kubectl k' >>~/.bash_aliases
echo 'alias kctx=kubectx' >>~/.bash_aliases
echo 'alias kns=kubens' >>~/.bash_aliases
source ~/.bash_aliases
