# Create Namespace - prod
CONTROL_PLANE_IP=10.220.41.226
TANZU_TOOLS_FILES_PATH="/mnt/c/Dev/workspaces/tanzu-tools"

# Connect
sh login-mgmt.sh
kctx $CONTROL_PLANE_IP

# Deploy Cluster
k apply -f $TANZU_TOOLS_FILES_PATH/tkgs/data/workload-prod-tanzu.yaml
kubectl get tkc -n prod

# Connect
sh login-cluster-prod.sh
kctx tanzu-cluster-prod

k delete node 

# Day 2
kctx $CONTROL_PLANE_IP

cat $TANZU_TOOLS_FILES_PATH/tkgs/data/workload-dev-tanzu.yaml

- upgrade
- scale
- delete

# Release
k get tkr
