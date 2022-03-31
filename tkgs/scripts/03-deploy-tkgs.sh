
# Login to management
kubectl vsphere login --server $CONTROL_PLANE_IP --vsphere-username $GOVC_USERNAME --insecure-skip-tls-verify
kubectl config use-context prod

# Deploy
# https://docs.vmware.com/fr/VMware-vSphere/7.0/vmware-vsphere-with-tanzu/GUID-4E68C7F2-C948-489A-A909-C7A1F3DC545F.html
k apply -f $TANZU_TOOLS_FILES_PATH/tkgs/data/workload-prod-tanzu.yaml

# API v2
# https://docs.vmware.com/en/VMware-vSphere/7.0/vmware-vsphere-with-tanzu/GUID-B2807BCD-0CE1-4C3A-9C0E-2B78F5DA0E90.html

# Check
kubectl get tanzukubernetesclusters
kubectl describe tanzukubernetescluster tanzu-cluster-prod

# Commandes opérationnelles du cluster Tanzu Kubernetes
# https://docs.vmware.com/fr/VMware-vSphere/7.0/vmware-vsphere-with-tanzu/GUID-232CCCF3-CCC1-4D7E-B67C-64590CB891DD.html

# Login to tanzu-cluster
kubectl vsphere login --server $CONTROL_PLANE_IP \
--vsphere-username $GOVC_USERNAME \
--insecure-skip-tls-verify \
--tanzu-kubernetes-cluster-name tanzu-cluster-shared \
--tanzu-kubernetes-cluster-namespace shared

kubectl config get-contexts
kubectl config use-context prod

# Configure roles
# https://docs.vmware.com/en/VMware-vSphere/7.0/vmware-vsphere-with-tanzu/GUID-CD033D1D-BAD2-41C4-A46F-647A560BAEAB.html
k get ClusterRole
k get ClusterRole psp:vmware-system-privileged
k get psp

# Disable PSP
kubectl create clusterrolebinding default-tkg-admin-privileged-binding --clusterrole=psp:vmware-system-privileged --group=system:authenticated

# Allow SA to deploy in the test ns
k apply -f $K8S_FILES_PATH/rbac/role-binding-sa-test.yaml

# Developper account
# https://docs.vmware.com/en/VMware-vSphere/7.0/vmware-vsphere-with-tanzu/GUID-6DE4016E-D51C-4E9B-9F8B-F6577A18F296.html


###########################################
# kapp-controller
###########################################
# https://docs.vmware.com/en/VMware-vSphere/7.0/vmware-vsphere-with-tanzu/GUID-00A2BB49-DBDE-4E2B-B9EE-38C36E261185.html
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-packages-prep-tkgs-kapp.html

# kapp-controller, not required when integrated with TMC
kctx tanzu-cluster-prod
# Check if exists
kubectl get pods -A | grep kapp-controller
kubectl apply -f $TANZU_TOOLS_FILES_PATH/tkgs/data/tanzu-system-kapp-ctrl-restricted.yaml
kubectl apply -f $TANZU_TOOLS_FILES_PATH/tkgs/data/kapp-controller.yaml

# Add repository
tanzu package repository add tanzu-repository --url projects.registry.vmware.com/tkg/packages/standard/repo:v1.4.0 -n $USER_PACKAGE_NAMESPACE
# Check
tanzu package repository list -A
tanzu package available list -n $USER_PACKAGE_NAMESPACE

# Ensure PSP are disabled

###########################################
# Add a vSphere7 Supervisor Cluster as a Management Cluster
###########################################
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-tanzu-k8s-clusters-connect-vsphere7.html
kctx $SUPERVISOR_IP
tanzu login --name supervisor --context $SUPERVISOR_IP

# Check
tanzu login

###########################################
# Shared
###########################################
kubectl config use-context $NAMESPACE_SHARED
k apply -f $TANZU_TOOLS_FILES_PATH/tkgs/data/workload-shared-tanzu.yaml

# Check
kubectl get tanzukubernetesclusters -n shared

# Login to tanzu-cluster
kubectl vsphere login --server $CONTROL_PLANE_IP \
--vsphere-username administrator@vsphere.local \
--insecure-skip-tls-verify \
--tanzu-kubernetes-cluster-name tanzu-cluster-shared \
--tanzu-kubernetes-cluster-namespace shared

###########################################
# TO
###########################################
# This doesn't work, disabling all PSP does
k apply -f $TANZU_TOOLS_FILES_PATH/tkgs/data/ClusterRoleBindingTo.yaml


############################################
# TMC
###########################################
# https://docs.vmware.com/en/VMware-Tanzu-Mission-Control/services/tanzumc-using/GUID-CC6E721E-43BF-4066-AA0A-F744280D6A03.html

kubectl config use-context CONTEXT-NAME-IP
# Update ns and url in tmc-registration.yaml
kubectl create -f $TANZU_TOOLS_FILES_PATH/tkgs/data/tmc-registration.yaml

# Check
kubectl -n svc-tmc-c8 describe agentinstall tmc-agent-installer-config