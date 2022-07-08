###########################################
# Security Policy
###########################################
# https://docs.vmware.com/en/VMware-Tanzu-Mission-Control/services/tanzumc-using/GUID-8E9E8345-5213-4049-9C14-4D4CDD983B27.html

# Disable policy enforcement to test
# Sample to Ensure containers are not run with root privileges
Policies > Assignment > Security > aks-tanzu-fmartin > Create Security Policy
Custom > Add all Allow Privilege & Container runAsUser & Disable policy enforcement
Follow the status on TMC > Policies > Insights page (Not in standard)

# Verify Gatekeeper is installed
kubectl -n gatekeeper-system get pods
k logs --follow gatekeeper-audit-66db46f5f8-gdk45 -n gatekeeper-system

# Get Policies
kubectl get opapolicies

# Get status to check violations
# The actual resources that enforce the policy are constraint and ConstraintTemplate resources of OPA Gatekeeper. 
# https://open-policy-agent.github.io/gatekeeper/website/docs/howto/
kubectl get constraint

# Check Policy
k apply -f $TANZU_TOOLS_FILES_PATH/tmc/k8s/runAsRoot.yaml
kubectl exec nginx-77959bf944-wpmtc -it -- /bin/sh
whoami

# The reason is present in the describe of the replicaset

###########################################
# Custom Template
###########################################
# TMC template and implementation details
kubectl get constrainttemplate
kubectl get policydefinition

# Template for runAsUser
kubectl get constrainttemplate vmware-system-tmc-allowed-users-v1 -o yaml

# Use custom Policy
Add a Custom Template as defined in template-runAs.yaml
Assign it with
 - Pod * > Add Resource
 - MustRunAsNonRoot
 - Disable policy enforcement


###########################################
# Network
###########################################
# Create Namespaces
tmc cluster namespace create -n blue -c $CLUSTER_NAME -k $WORKSPACE_NAME -l color=blue
tmc cluster namespace create -n green -c $CLUSTER_NAME -k $WORKSPACE_NAME -l color=green

k apply -f $TANZU_TOOLS_FILES_PATH/tmc/k8s/namespacesNetwork.yaml
k get pods -n blue
k get pods -n green

# Check Connectivity
k exec -it nginx -n blue -- /bin/sh
curl nginx.blue.svc.cluster.local
curl nginx.green.svc.cluster.local

# Disable Connectivity to Green
# Create a Network Policy on the Workspace
Policies > Assignments > Network
Type : deny-all
Name : fmartin-deny-green
Include only specific namespaces : color | green > Add Label Selector

=> Curl are now disabled

# Delete
k delete -f $TANZU_TOOLS_FILES_PATH/tmc/k8s/namespacesNetwork.yaml
tmc cluster namespace delete blue --cluster-name $CLUSTER_NAME
tmc cluster namespace delete green --cluster-name $CLUSTER_NAME

