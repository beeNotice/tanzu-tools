# Preparation
K8S_FILES=/mnt/c/Dev/workspaces/tanzu-simple/tanzu-simple/k8s/
cat image.yaml

k apply -f image.yaml
k apply -f $K8S_FILES

https://harbor-fmartin-tanzu.francecentral.cloudapp.azure.com

k get svc -n tanzu-simple

# Demo
kp build logs tanzu-simple -n build
kp image status tanzu-simple -n build

kp clusterbuilder patch demo-builder --stack new
kp build list -n build

# Clean
k delete -f image.yaml
k delete -f $K8S_FILES
Delete Harbor image

kp clusterbuilder patch demo-builder --stack old
