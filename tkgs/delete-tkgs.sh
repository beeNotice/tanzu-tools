k delete -f $TANZU_TOOLS_FILES_PATH/tkgs/data/workload-shared-tanzu.yaml

kubectl config view
kubectl config get-contexts

kubectl config delete-context shared
kubectl config delete-cluster my-cluster
kubectl config delete-user clusterUser_rg-tanzu-demo_aks-tanzu-demo

# Remove all
kubectl config unset contexts
kubectl config unset clusters
kubectl config unset users
