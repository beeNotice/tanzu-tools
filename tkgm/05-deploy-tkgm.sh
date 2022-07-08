#!/bin/bash

# Launch GUI
tanzu management-cluster create --ui --browser none
# Retrieve SSH Key
cat /home/tanzu/.ssh/id_rsa.pub

# Proxy configuration
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-tanzu-config-reference.html#proxy-configuration-5
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-mgmt-clusters-create-config-file.html#proxies

# Create management
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-mgmt-clusters-config-vsphere.html
tanzu management-cluster create --file /home/tanzu/tanzu-mgt.yaml

# Check management
tanzu management-cluster get
tanzu management-cluster kubeconfig get --admin
kubectl config use-context tanzu-mgt-admin@tanzu-mgt

kubectl get apps -A
k get pods -A

# Create workload
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-tanzu-k8s-clusters-vsphere.html#tanzu-kubernetes-cluster-template-0
tanzu cluster create --file tanzu-wkl.yaml

# Check workload
tanzu cluster list
tanzu cluster kubeconfig get tanzu-wkl --admin
kubectl config use-context tanzu-wkl-admin@tanzu-wkl

kubectl get nodes -o wide
ssh capv@$node-ip
k get pods -A
