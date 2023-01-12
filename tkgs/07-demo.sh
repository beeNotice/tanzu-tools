# Create Namespace - prod

# Connect
sudo su tkgs
cd

sh login-mgmt.sh
kctx 10.220.1.226

# Deploy Cluster
k apply -f workload-prod-tanzu.yaml
k get tkc -n prod

# Connect
sh login-cluster-prod.sh

- scale
- upgrade
- delete

# Release
k get tkr

k get nodes