# Install
https://docs.vmware.com/en/Tanzu-Application-Platform/1.0/tap/GUID-install-intro.html
https://github.com/pvdbleek/tanzu/tree/main/tap-minikube

# Azure VM
D8s_v3
8 vcPU / 32 RAM

Stop VM / Update Disk size
P20 / 512 GiB

# https://brew.sh/
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/tanzu/.profile
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
sudo apt-get install -y build-essential

# Docker
# https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm get-docker.sh 
sudo adduser ${VM_USER} docker

# Minikube
brew install gcc minikube kubectl
minikube config set driver docker
minikube config set memory 28672M
minikube config set cpus 8
minikube start

# https://docs.vmware.com/en/Tanzu-Application-Platform/1.0/tap/GUID-install-general.html#install-cluster-essentials-for-vmware-tanzu-6
# https://network.tanzu.vmware.com/products/tanzu-cluster-essentials/
mkdir $HOME/tanzu-cluster-essentials
tar -xvf $TANZU_TOOLS_FILES_PATH/binaries/tanzu-cluster-essentials-linux-amd64-1.0.0.tgz -C $HOME/tanzu-cluster-essentials

export INSTALL_BUNDLE=registry.tanzu.vmware.com/tanzu-cluster-essentials/cluster-essentials-bundle@sha256:82dfaf70656b54dcba0d4def85ccae1578ff27054e7533d08320244af7fb0343
export INSTALL_REGISTRY_HOSTNAME=registry.tanzu.vmware.com
export INSTALL_REGISTRY_USERNAME=$TANZU_NET_USER
export INSTALL_REGISTRY_PASSWORD=$TANZU_NET_PASSWORD
cd $HOME/tanzu-cluster-essentials
./install.sh
cd

sudo cp $HOME/tanzu-cluster-essentials/kapp /usr/local/bin/kapp

# https://docs.vmware.com/en/Tanzu-Application-Platform/1.0/tap/GUID-install-general.html#clean-install-tanzu-cli-8
mkdir $HOME/tanzu
# https://network.tanzu.vmware.com/products/tanzu-application-platform/
tar -xvf tanzu-framework-linux-amd64.tar -C $HOME/tanzu
export TANZU_CLI_NO_INIT=true

cd $HOME/tanzu
sudo install cli/core/v0.10.0/tanzu-core-linux_amd64 /usr/local/bin/tanzu
tanzu plugin install --local cli all

# https://docs.vmware.com/en/Tanzu-Application-Platform/1.0/tap/GUID-install.html
kubectl create ns tap-install

# TAP installation
# https://docs.vmware.com/en/Tanzu-Application-Platform/1.0/tap/GUID-install.html
minikube ip
# Fill data

tanzu package install tap \
     -p tap.tanzu.vmware.com \
     -v 1.0.0 \
     --values-file tap-values.yml \
     -n tap-install
# Check
tanzu package installed get tap -n tap-install
tanzu package installed list -A

# Setup developper workspace
# https://docs.vmware.com/en/Tanzu-Application-Platform/1.0/tap/GUID-install-components.html#setup
tanzu secret registry add registry-credentials \
--server https://harbor.withtanzu.com \
--username $HARBOR_USER \
--password $HARBOR_PASS \
--namespace default

+ RBAC


###########################################
# Day 2
###########################################
minikube stop
minikube start

tanzu package installed update tap \
    -p tap.tanzu.vmware.com \
    -v 1.0.0 \
    --values-file tap-values-full.yml \
    -n tap-install

# Installing Tanzu Dev Tools for VSCode

###########################################
# Deploy
###########################################

git clone https://github.com/beeNotice/spring-sensors-rabbit.git

# Deploy Rabbit
kubectl apply -f "https://github.com/rabbitmq/cluster-operator/releases/latest/download/cluster-operator.yml"
kubectl apply -f spring-sensors-rabbit/rabbit/cluster.yaml
kubectl apply -f spring-sensors-rabbit/rabbit/rbac.yaml

# Create Workload
tanzu apps workload create spring-sensors -f spring-sensors-rabbit/config/workload.yaml

# Check
tanzu apps workload tail spring-sensors --since 1h

tanzu apps workload list
tanzu app workload get spring-sensors

# TBS
kp image list
kp build logs spring-sensors
kp image status spring-sensors
kp build list spring-sensors


# Register to live view
# https://docs.vmware.com/en/Tanzu-Application-Platform/1.0/tap/GUID-getting-started.html#add-your-application-to-tanzu-application-platform-gui-software-catalog-5

# Installing Application Live View Conventions installation bundle
# https://docs.vmware.com/en/Application-Live-View-for-VMware-Tanzu/1.0/docs/GUID-installing.html#verify-the-application-live-view-components-5
tanzu secret registry add tanzu-net-credentials \
--server https://registry.tanzu.vmware.com \
--username $TANZU_NET_USER \
--password $TANZU_NET_PASSWORD \
--namespace default

# Delete Workload
tanzu apps workload delete spring-sensors
