#!/bin/bash

# Common
sudo apt-get update
sudo apt-get -y install curl grep sed jq unzip bash-completion dos2unix bash-completion
sudo snap install yq
sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' .bashrc

# SSH Key
ssh-keygen -t rsa -b 4096

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