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
k apply -f runAsRoot.yaml
kubectl exec nginx-77959bf944-wpmtc -it -- /bin/sh
whoami

# The reason is present in the describe of the replicaset

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


# Network
k apply -f namespacesNetwork.yaml
k get pods -n blue
k get pods -n green

# Check Connectivity
k exec -it nginx -n blue -- /bin/sh
curl nginx.blue.svc.cluster.local
curl nginx.green.svc.cluster.local

# Disable Connectivity to Green
Create Workspace with the namespaces
Add labels to the namespaces color | green & color | blue
Create a Network Policy on the Workspace

Type : deny-all
Name : fmartin-deny-green
Include only specific namespaces : color | green > Add Label Selector

=> Curl are now disabled






# Authentication
# https://docs.vmware.com/en/VMware-Tanzu-Mission-Control/services/tanzumc-concepts/GUID-EB9C6D83-1132-444F-8218-F264E43F25BD.html
# https://docs.vmware.com/en/VMware-Tanzu-Mission-Control/services/tanzumc-concepts/GUID-9A4D2BA3-C84B-4DB8-927F-6BF5408515E0.html#GUID-9A4D2BA3-C84B-4DB8-927F-6BF5408515E0
# https://docs.vmware.com/en/VMware-Tanzu-Mission-Control/services/tanzumc-using/GUID-CA5A31BC-4D7B-4EDD-A4C8-95BEEC08F7C4.html
