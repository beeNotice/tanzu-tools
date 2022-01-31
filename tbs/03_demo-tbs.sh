# TKGm
tanzu cluster kubeconfig get prod --admin
kubectl config use-context prod-admin@prod

# TKGs
kubectl vsphere login --server $CONTROL_PLANE_IP \
--vsphere-username administrator@vsphere.local \
--insecure-skip-tls-verify \
--tanzu-kubernetes-cluster-name tanzu-cluster-shared \
--tanzu-kubernetes-cluster-namespace shared

# Deploy app
k apply -f $TANZU_APP_FILES_PATH/k8s

# Kubernetes CRD
k get images.kpack.io tanzu-app -n build-service-builds -o yaml | yq e '.spec' -

# Status
kp build logs tanzu-app --namespace build-service-builds
kp image status tanzu-app --namespace build-service-builds
kp build list tanzu-app --namespace build-service-builds

# Trigger manually
kp image trigger tanzu-app --namespace tanzu-app

# Access Harbor
https://harbor.withtanzu.com/harbor/projects

# Patch
kp clusterbuilder patch default --stack new
kp build list tanzu-app --namespace build-service-builds

# Deploy app
k apply -f /mnt/workspaces/tanzu-app/k8s/
kubectl set image deployment/app app=harbor.cpod-devready.az-fkd.cloud-garage.net/tls/tanzu-app@sha256:7c6065fe4c8940b9ae786706378395358d4a04f22cd7f69617ff435eae77dda7 -n tanzu-app

# Status
k get pods -n tanzu-app
k rollout status deployment app -n tanzu-app
