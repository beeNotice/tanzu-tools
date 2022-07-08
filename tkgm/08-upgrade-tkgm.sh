


# Install previous version
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.5/vmware-tanzu-kubernetes-grid-15/GUID-tanzu-k8s-clusters-k8s-versions.html
# Import Previous OVA version (see tkg-terraforming-vsphere setup-jumpbox.sh)
tanzu kubernetes-release get
tanzu cluster create --file $HOME/.config/tanzu/tkg/clusterconfigs/dev01-cluster-config.yaml --tkr v1.21.11---vmware.1-tkg.3
tanzu cluster kubeconfig get dev01 --admin
kubectl config use-context dev01-admin@dev01

# List current version
k get nodes
tanzu cluster list --include-management-cluster

# Upgrade version
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.5/vmware-tanzu-kubernetes-grid-15/GUID-upgrade-tkg-workload-clusters.html

# List available releases
tanzu kubernetes-release get
tanzu kubernetes-release available-upgrades get v1.21.11---vmware.1-tkg.3
tanzu cluster available-upgrades get dev01

# Prepare scripts to check continuity
k apply -f $K8S_FILES_PATH/sample/01-namespace.yaml
k apply -f $K8S_FILES_PATH/sample/02-secret.yaml
kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "docker-hub-creds"}]}' --namespace=test
k apply -f $K8S_FILES_PATH/sample/03-deployment.yaml
k apply -f $K8S_FILES_PATH/sample/04-service.yaml
k get pods -n test

# Continuous curl while upgrade
sh $TANZU_TOOLS_FILES_PATH/tools/curl-loop.sh

# Perform upgrade
tanzu cluster upgrade dev01
