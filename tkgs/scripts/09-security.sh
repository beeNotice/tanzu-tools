# https://docs.vmware.com/en/VMware-vSphere/7.0/vmware-vsphere-with-tanzu/GUID-93B29112-4492-431F-958A-12323540C38D.html
# https://docs.vmware.com/en/VMware-vSphere/7.0/vmware-vsphere-with-tanzu/GUID-6DE4016E-D51C-4E9B-9F8B-F6577A18F296.html
# https://docs.vmware.com/en/VMware-vSphere/7.0/vmware-vsphere-with-tanzu/GUID-CD033D1D-BAD2-41C4-A46F-647A560BAEAB.html
# https://williamlam.com/2021/07/closer-look-at-vsphere-permissions-for-vsphere-with-tanzu.html

# https://kubernetes.io/docs/reference/access-authn-authz/rbac/#role-and-clusterrole
Administration > SSO > Users and Groups
Domain :  vsphere.local > Add
fmartin > Fmartin2022!

# Create Group
Groups > Add > tanzu-dev + Add fmartin as Member

###########################################
# DevOps Engineers - 
###########################################
1/ K8s connexion

Create the namespace as Administrator
Add fmartin in the Permissions as Owner

Give him the URL of the Kubernetes control plane
This user can now login and perform operation to the assigned Namespace

1/ vCenter connexion
You can Allow them to connect to vCenter

Administration > SSO > Users and Groups > ServiceProviderUsers
Administration > Access Control > Global Permissions > Add > fmartin | Read Only
WARN: Do not forget to check "Propagate to children"

###########################################
# Custom RoleBindings
###########################################

# https://kubernetes.io/docs/reference/access-authn-authz/authorization/
# Check to see if I can do everything in my current namespace ("*" means all)
kubectl auth can-i '*' '*'
# Check to see if I can create pods in any namespace
kubectl auth can-i create pods --all-namespaces
# Check to see if I can list deployments in my current namespace
kubectl auth can-i list deployments
# Check impersonate
kubectl auth can-i list pods --namespace default --as sso:fmartin@vsphere.local

# API Groups
# https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.23/#-strong-api-groups-strong-

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

# Audit
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-troubleshooting-tkg-audit-logging.html

# Connect to the Control Plane Node following : 99-troubleshooting.adoc

# Audit is enabled by default on TKGs
# API server audit logging
# https://vmware.slack.com/archives/CQW2Q05DW/p1618544659013600

sudo tail -500 /var/log/kubernetes/kube-apiserver.log
sudo cat /etc/kubernetes/extra-config/audit-policy.yaml
sudo tail -f /var/log/kubernetes/kube-apiserver.log | grep -C3 administrator
