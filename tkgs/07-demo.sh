# Create Namespace - prod

# Connect
sh login-mgmt.sh
kctx 10.220.50.98

# Deploy Cluster
k apply -f /mnt/c/Dev/workspaces/tanzu-tools/tkgs/data/workload-prod-tanzu.yaml
k get tkc -n prod

# Connect
sh login-cluster-prod.sh
kctx tanzu-cluster-prod

# Day 2
kctx 10.220.50.98
- scale
- delete

# Release
k get tkr
