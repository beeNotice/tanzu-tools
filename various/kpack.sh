# Env
TANZU_TCE_FILES_PATH=/mnt/c/Dev/workspaces/tanzu-tools/tce/

# AKS
RG_NAME=rg-tanzu-talk-ncb
CLUSTER_NAME=aks-tanzu-talk-ncb

# Deploy
az group create --location francecentral --name ${RG_NAME}
az aks create --resource-group ${RG_NAME} --name ${CLUSTER_NAME} --node-count 1 --enable-addons monitoring --node-vm-size Standard_DS4_v2 --node-osdisk-size 500 --enable-pod-security-policy
az aks get-credentials --resource-group ${RG_NAME} --name ${CLUSTER_NAME}

kubectl create clusterrolebinding tap-psp-rolebinding --group=system:authenticated --clusterrole=psp:privileged

# Install
https://github.com/pivotal/kpack/blob/main/docs/tutorial.md

docker login $HARBOR_URL -u admin
k apply -f $TANZU_TCE_FILES_PATH/kpack/

# Check
k get clusterstore
k get clusterstack
k get clusterbuilder

