# Prepare conf
tanzu cluster create tanzu-wkl -f cluster-config.yaml
tanzu cluster create tanzu-wkl -f cluster-config.yaml --tkr v1.20.14---vmware.1-tkg.2

# List Clusters
tanzu cluster list
tanzu cluster kubeconfig get tanzu-wkl --admin
kubectl config use-context tanzu-wkl-admin@tanzu-wkl
k get nodes

tanzu cluster scale fmartin-tkg-wkl-pez-435 --worker-machine-count 2
tanzu cluster list

# Sample App
k apply -f standalone.yaml
k get pods -n tanzu-simple
k get svc -n tanzu-simple

# Lifecycle
tanzu kubernetes-release get
tanzu cluster available-upgrades get tanzu-wkl
tanzu cluster upgrade -h
tanzu cluster upgrade tanzu-wkl --tkr v1.21.8

# Packages
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-packages-user-managed-index.html
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-packages-cert-manager.html

tanzu package available list
tanzu package available list cert-manager.tanzu.vmware.com -A
tanzu package installed list -A

# Storage
# Cluster > Monitor > Cloud Native Storage
k apply -f pvc.yaml

# Delete
tanzu cluster delete tanzu-wkl
kubectl config delete-context tanzu-wkl-admin@tanzu-wkl