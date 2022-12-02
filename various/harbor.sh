# Azure VM
# https://learn.microsoft.com/en-us/azure/virtual-machines/linux/tutorial-manage-vm
RG_NAME=harbor-fmartin
VM_NAME=vm-harbor-fmartin

az group create --name $RG_NAME --location francecentral

az vm create \
    --resource-group $RG_NAME \
    --name $VM_NAME \
    --image Canonical:0001-com-ubuntu-server-focal:20_04-lts:20.04.202209200 \
    --admin-username fmartin \
    --size Standard_D2_v2 \
    --public-ip-sku Standard \
    --generate-ssh-keys

az vm auto-shutdown --resource-group $RG_NAME --name $VM_NAME --time 2130
 
az vm open-port --resource-group $RG_NAME --name $VM_NAME --port 443 --priority 899
az vm open-port --resource-group $RG_NAME --name $VM_NAME --port 80 --priority 900

VM_IP=$(az vm list-ip-addresses --resource-group $RG_NAME --name $VM_NAME --query "[].virtualMachine.network.publicIpAddresses[0].ipAddress" --output tsv)
ssh fmartin@$VM_IP

# Set DNS - harbor-fmartin-tanzu
# harbor-fmartin-tanzu.francecentral.cloudapp.azure.com

sudo snap install certbot --classic
sudo certbot certonly --standalone -d harbor-fmartin-tanzu.francecentral.cloudapp.azure.com

wget https://github.com/goharbor/harbor/releases/download/v2.6.0/harbor-online-installer-v2.6.0.tgz
tar xvf harbor-online-installer-v2.6.0.tgz

cd harbor
cp harbor.yml.tmpl harbor.yml
vi harbor.yml

# Certificate is saved at: /etc/letsencrypt/live/harbor-fmartin-tanzu.francecentral.cloudapp.azure.com/fullchain.pem
# Key is saved at:         /etc/letsencrypt/live/harbor-fmartin-tanzu.francecentral.cloudapp.azure.com/privkey.pem

sudo ./install.sh

# https://medium.com/swlh/setup-harbor-with-lets-encrypt-c9632cdd6fd9

# Stop
cd harbor
sudo docker compose down -v
sudo shutdown now


# Day 2
https://goharbor.io/docs/2.6.0/install-config/reconfigure-manage-lifecycle/

cd harbor
sudo docker compose down -v
sudo ./prepare --with-trivy
sudo docker compose up -d


https://harbor-fmartin-tanzu.francecentral.cloudapp.azure.com
admin
Azerty12345!


