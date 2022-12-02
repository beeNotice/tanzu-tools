kubectl get tanzukubernetesreleases

# Horizontal scaling
kctx prod
# Update worker count
k apply -f $TANZU_TOOLS_FILES_PATH/tkgs/data/workload-prod-tanzu.yaml
# Check
kubectl get tanzukubernetesclusters
kctx tanzu-cluster-prod
k get nodes


# Upgrade
kctx shared

# https://docs.vmware.com/en/VMware-vSphere/7.0/vmware-vsphere-with-tanzu/GUID-292482C2-A5FA-44B5-B26E-F887A91BB19D.html
kubectl get tanzukubernetesreleases

# Update
# https://docs.vmware.com/en/VMware-vSphere/7.0/vmware-vsphere-with-tanzu/GUID-A7A0BC51-F49D-4E08-B4DD-782D84CB3762.html

kubectl edit tanzukubernetescluster tanzu-cluster-shared

# Update the TKR NAME string in the
#  - spec.topology.controlPlane.tkr.refernece.name
#  - spec.topology.nodePools[*].tkr.reference.name


# Connect to supervisor Cluster
kctx IP
kubectl get tanzukubernetesclusters -A
kubectl edit tanzukubernetescluster clusterName -n namesPace name

