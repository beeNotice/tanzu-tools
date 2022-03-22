###########################################
# Keel
###########################################
# https://keel.sh/docs/#deploying-with-kubectl
kubectl apply -f https://sunstone.dev/keel?namespace=keel&username=admin&password=admin&tag=latest
kubectl -n keel get pods

###########################################
# Application
###########################################

# App presentation + Local start

###########################################
# Image
###########################################
[source, sh]
.Declare Image
----
# Building pods will be deployed in the namespace
k create ns build-service-builds
kp image create tanzu-app \
  --tag harbor.withtanzu.com/fmartin/tanzu-app \
  --namespace build-service-builds \
  --wait \
  --git https://github.com/beeNotice/tanzu-app.git \
  --git-revision main

https://buildpacks.io/

# Kubernetes CRD
k get images.kpack.io tanzu-app -n build-service-builds -o yaml

# Check image status
kp image list -n build-service-builds
kp image status tanzu-app -n build-service-builds
----

###########################################
# Registry
###########################################
# Move to Harbor
# Do not show Scan yet, come back later

###########################################
# Kubernetes
###########################################
# K8s files & organisation
ytt -f $TANZU_TOOLS_FILES_PATH/k8s-template/01-namespace.yaml -f $TANZU_TOOLS_FILES_PATH/k8s-template/dev.yml

# Deploy
k apply -f $TANZU_TOOLS_FILES_PATH/k8s
k get svc -n tanzu-app

# Check Build Service Optimizations
k get pods -n tanzu-app
k logs tanzu-app-xxx -n tanzu-app

# Update feature flag & apply
k apply -f $TANZU_TOOLS_FILES_PATH/k8s
k delete pod tanzu-app-xxx -n tanzu-app
k logs tanzu-app-xxx -n tanzu-app

###########################################
# Image patch
###########################################
[source, sh]
.Patch Image
----
kp clusterbuilder patch default --stack base
kp clusterbuilder patch default --stack old

kp build list -n build-service-builds
kp build logs tanzu-app -n build-service-builds
----

###########################################
# TO
###########################################