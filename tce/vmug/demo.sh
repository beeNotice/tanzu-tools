###########################################
# VM
###########################################
az group create -l francecentral -n rg-tanzu

# Create VM
az vm create \
    --resource-group rg-tanzu \
    --name tce-demo \
    --image UbuntuLTS \
    --size Standard_DS3_v2 \
    --admin-username tanzu \
    --ssh-key-values @~/.ssh/id_rsa.pub \
    --public-ip-sku Standard \
    --public-ip-address-dns-name tce-demo-fmartin

# Open port
az vm open-port \
  --nsg-name open-http \
  --port 80 \
  --priority 1100 \
  --resource-group rg-tanzu \
  --name tce-demo

# Connect
ssh tanzu@tce-demo-fmartin.francecentral.cloudapp.azure.com

###########################################
# Install
# https://tanzucommunityedition.io/docs/v0.12/cli-installation/
###########################################

# Install K8s CLI.
if ! [ -f /usr/local/bin/kubectl ]; then
  K8S_VERSION=v1.22.5
  curl -LO https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    sudo install ./kubectl /usr/local/bin/kubectl && \
    rm ./kubectl
    echo 'alias k=kubectl' >> ~/.bashrc
fi

# Install Docker.
if ! [ -L /usr/local/bin/docker ]; then
  sudo apt-get update && \
    sudo apt-get -y install docker.io && \
    sudo ln -sf /usr/bin/docker.io /usr/local/bin/docker && \
    sudo usermod -aG docker tanzu
fi

# Tools
sudo apt-get -y install curl grep sed jq coreutils

# Reconnect
exit

# Tanzu CLI.
curl -H "Accept: application/vnd.github.v3.raw" \
    -L https://api.github.com/repos/vmware-tanzu/community-edition/contents/hack/get-tce-release.sh | \
    bash -s v0.12.0 linux
tar xzvf tce-linux-amd64-v0.12.0.tar.gz
cd tce-linux-amd64-v0.12.0
./install.sh
cd -

###########################################
# Deploy - Unmanaged Clusters
# https://tanzucommunityedition.io/docs/v0.12/getting-started-unmanaged/
###########################################
tanzu unmanaged-cluster create tce-local -p 80:80 -p 443:443

# Check
k get pods -A
k get nodes
tanzu unmanaged-cluster list

# Packages
tanzu package repository list --all-namespaces
tanzu package available list

# Cert-manager
tanzu package available list cert-manager.community.tanzu.vmware.com
tanzu package install cert-manager --package-name cert-manager.community.tanzu.vmware.com --version 1.8.0

tanzu package installed list

# Contour
wget "https://raw.githubusercontent.com/beeNotice/tanzu-tools/main/tce/data/contour-values.yaml"
tanzu package install contour \
  --package-name contour.community.tanzu.vmware.com \
  --version 1.20.1 \
  --values-file contour-values.yaml

# Check
tanzu package installed list
kubectl --namespace projectcontour get service envoy

# Application
k apply -f app.yaml
k get pods -n tanzu-simple

http://tce-demo-fmartin.francecentral.cloudapp.azure.com/

###########################################
# Clean
###########################################
tanzu unmanaged delete tce-local
az vm delete -g rg-tanzu -n tce-demo --yes