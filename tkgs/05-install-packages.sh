# Install CLI
vmd download -p vmware_tanzu_kubernetes_grid -s tkg -v 1.4.3 -f 'tanzu-cli-bundle-linux-amd64.tar' --accepteula
cp /home/ubuntu/vmd-downloads/tanzu-cli-bundle-linux-amd64.tar.gz /home/ubuntu/tanzu-cli.tar

# Install
https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-install-cli.html

# Check
tanzu plugin list
tanzu package repository list -A
kubectl get apps -A