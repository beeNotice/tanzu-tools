# Horizontal scale
tanzu cluster scale tanzu-wkl --worker-machine-count 3
tanzu cluster list --include-management-cluster
tanzu cluster get tanzu-wkl

# Vertical scale
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-cluster-lifecycle-scale-cluster.html#vertical-kubectl
kubectl get VsphereMachineTemplate tanzu-wkl-worker -o yaml > tanzu-wkl-worker-machine-template.yaml
# => Update name to tanzu-wkl-worker-updated & size
k apply -f tanzu-wkl-worker-machine-template.yaml
k edit MachineDeployment tanzu-wkl-md-0
# => Update spec.template.spec.infrastructureRef.name field to tanzu-wkl-worker-updated

# Upgrade version
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-upgrade-tkg-workload-clusters.html
# Import photon-3-kube-v1.20.8+vmware.1-tkg.2-9893064678268559535 OVA
tanzu cluster list --include-management-cluster
tanzu kubernetes-release get
tanzu cluster create --file tanzu-wkl.yaml --tkr v1.20.8---vmware.1-tkg.2

tanzu cluster list
tanzu cluster kubeconfig get tanzu-wkl-old --admin
kubectl config use-context tanzu-wkl-old-admin@tanzu-wkl-old

k apply -f $K8S_FILES_PATH/01-namespace.yaml
k apply -f $K8S_FILES_PATH/02-secret.yaml
k apply -f $K8S_FILES_PATH/03-deployment.yaml
k apply -f $K8S_FILES_PATH/04-service.yaml

# Continuous curl while upgrade
sh $TANZU_TOOLS_FILES_PATH/script/tools/curl-loop.sh

# Perform upgrade
tanzu cluster available-upgrades get tanzu-wkl-old
tanzu cluster upgrade tanzu-wkl-old
