###########################################
# Day 2
###########################################
# Start / Stop AKS
az aks start --resource-group rg-tanzu-tap --name aks-tanzu-tap
az aks stop --resource-group rg-tanzu-tap --name aks-tanzu-tap

# Update tap
tanzu package installed update tap \
     -p tap.tanzu.vmware.com \
     -v $TAP_VERSION \
     --values-file $TAP_FILES_PATH/data/tap-values-full.yml \
     -n tap-install

# Force Catalog refresh
k delete pod server-886d5b95f-tnq2j -n tap-gui

# Update TBS
docker login -u fmartin@vmware.com registry.pivotal.io
docker login -u fmartin@vmware.com registry.tanzu.vmware.com
docker login -u fma harbor.withtanzu.com

kp import -f tap-descriptor-<version>.yaml