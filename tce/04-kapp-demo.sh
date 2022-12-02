# Application
https://harbor-fmartin-tanzu.francecentral.cloudapp.azure.com
https://github.com/beeNotice/tanzu-simple

# Image description
cat image.yaml
kubectl apply -f image.yaml

kp build logs tanzu-simple -n build
kp build status tanzu-simple -n build

kp clusterbuilder patch demo-builder --stack new
kp build list -n build

# Image description

# Clean
kp clusterbuilder patch demo-builder --stack old
kubectl delete -f image.yaml

# Delete Harbor images
