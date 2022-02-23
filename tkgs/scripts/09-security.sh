# https://docs.vmware.com/en/VMware-vSphere/7.0/vmware-vsphere-with-tanzu/GUID-6DE4016E-D51C-4E9B-9F8B-F6577A18F296.html
# https://docs.vmware.com/en/VMware-vSphere/7.0/vmware-vsphere-with-tanzu/GUID-CD033D1D-BAD2-41C4-A46F-647A560BAEAB.html

# https://kubernetes.io/docs/reference/access-authn-authz/rbac/#role-and-clusterrole

Administration > SSO > Users and Groups
Domain :  vsphere.local > Add
fmartin > Fmartin2022!

# https://kubernetes.io/docs/reference/access-authn-authz/authorization/
# Check to see if I can do everything in my current namespace ("*" means all)
kubectl auth can-i '*' '*'
# Check to see if I can create pods in any namespace
kubectl auth can-i create pods --all-namespaces
# Check to see if I can list deployments in my current namespace
kubectl auth can-i list deployments
# Check impersonate
kubectl auth can-i list pods --namespace default --as sso:fmartin@vsphere.local

# Declare roles
k apply -f $K8S_FILES_PATH/rbac/RolePodReader.yaml
k apply -f $K8S_FILES_PATH/rbac/RoleBindingDev.yaml

# Perform login
kubectl vsphere login --server $CONTROL_PLANE_IP \
--vsphere-username fmartin@vsphere.local \
--insecure-skip-tls-verify \
--tanzu-kubernetes-cluster-name tanzu-cluster-shared \
--tanzu-kubernetes-cluster-namespace shared

# Check
kubectl auth can-i list pods --namespace default
k get pods
k get pods -n test
k get ns


# PSP
# https://docs.vmware.com/en/VMware-vSphere/7.0/vmware-vsphere-with-tanzu/GUID-CD033D1D-BAD2-41C4-A46F-647A560BAEAB.html