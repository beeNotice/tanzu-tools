###########################################
# Register Supervisor Cluster
###########################################
# TMC
Administration > Management Clusters > Register Management Cluster
# vCenter
Workload Management > Supervisor Cluster > Configure > TKG Service > Tanzu Mission Control > Paste url

###########################################
# Create Cluster
###########################################
Create & configure vSphere Namespace
Create cluster using TMC



###########################################
# Deploy packages
###########################################
# Disable PSP
kubectl create clusterrolebinding default-tkg-admin-privileged-binding --clusterrole=psp:vmware-system-privileged --group=system:authenticated

# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.5/vmware-tanzu-kubernetes-grid-15/GUID-packages-index.html
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-packages-index.html
Today, you cannot install Tanzu Standard repository v1.5 packages into TKGs
One way to add pkg repo 1.4.2 is to disable 1.5 and add the 1.4.2 repo

Cluster > Add-ons > Add
    - tanzu-standard-tkgs
    - projects.registry.vmware.com/tkg/packages/standard/repo:v1.4.0
Disable 1.5.2

NOTE: Synch will fail until 1.5.2 is disabled
