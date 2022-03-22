
Vérifier la santé du cluster Tanzu Kubernetes
https://docs.vmware.com/fr/VMware-vSphere/7.0/vmware-vsphere-with-tanzu/GUID-AFAAD7D6-8EF9-41EC-A6FC-ACCD802E0787.html

Vérifier la santé de la machine Tanzu Kubernetes
https://docs.vmware.com/fr/VMware-vSphere/7.0/vmware-vsphere-with-tanzu/GUID-644993CC-1DAF-4CAF-99BF-964AF4661677.html

SSH connexion
https://docs.vmware.com/en/VMware-vSphere/7.0/vmware-vsphere-with-tanzu/GUID-37DC1DF2-119B-4E9E-8CA6-C194F39DDEDA.html

ssh jumpbox



# Retrieve secret
kctx shared

# Retrieve IP
kubectl get virtualmachines -o wide

# Retrieve secret
kubectl get secrets tanzu-cluster-shared-ssh-password -o yaml | yq e '.data.ssh-passwordkey' - | base64 --decode
ssh vmware-system-user@TKGS-CLUSTER-NODE-IP-ADDRESS
