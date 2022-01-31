kubectl get tanzukubernetesreleases

# Horizontal scaling
kctx prod
# Update worker count
k apply -f $TANZU_TOOLS_FILES_PATH/tkgs/data/workload-prod-tanzu.yaml
# Check
kubectl get tanzukubernetesclusters
kctx tanzu-cluster-prod
k get nodes