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

###########################################
# Custom certificate
###########################################
# To register custom CA on all Clusters
https://docs.vmware.com/fr/VMware-vSphere/7.0/vmware-vsphere-with-tanzu/GUID-376FCCD1-7743-4202-ACCA-56F214B6892F.html

# Retrieve certificate
echo | openssl s_client -servername harbor -connect vc01.h2o-4-946.h2o.vmware.com:443 |\
  sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > certificate.crt

# Check that the certificate is good
curl --cacert certificate.crt https://vc01.h2o-4-946.h2o.vmware.com:443

# To edit an existing Cluster
# https://docs.vmware.com/fr/VMware-vSphere/7.0/vmware-vsphere-with-tanzu/GUID-31BF8166-5FC8-4D43-933D-5797F3BE4A36.html

k edit TanzuKubernetesCluster fmartin-prod-tmc

trust: 
  additionalTrustedCAs:
    - name: harbor
    data: base64encoded

# Check (VM will be recreated)
k get TanzuKubernetesCluster fmartin-prod-tmc -o yaml
kubectl run busybox --image=xxxx


