# https://docs.vmware.com/en/VMware-Tanzu-Mission-Control/services/tanzumc-using/GUID-8E9E8345-5213-4049-9C14-4D4CDD983B27.html

# Disable policy enforcement to test
# You can also follow the status on TMC > Policies > Insights page (Not in standard)

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

# TMC implementation details
kubectl get constrainttemplate
kubectl get policydefinition

