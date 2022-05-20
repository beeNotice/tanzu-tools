# Application
https://github.com/beeNotice/tanzu-simple

# Image description
cat image.yaml
kubectl apply -f image.yaml

kp build logs tanzu-simple -n build
kp build status tanzu-simple -n build

# Access App
k get pods -n tanzu-simple
http://tanzu-tce-fmartin.francecentral.cloudapp.azure.com

# Patch
https://harbor.withtanzu.com/harbor/projects/9/repositories/tanzu-simple
http://tanzu-tce-fmartin.francecentral.cloudapp.azure.com/actuator/info

kp clusterbuilder patch demo-builder --stack new

kp build list -n build

https://harbor.withtanzu.com/harbor/projects/9/repositories/tanzu-simple
http://tanzu-tce-fmartin.francecentral.cloudapp.azure.com/actuator/info

https://harbor.withtanzu.com/harbor/projects/9/repositories/cnb-nodejs














# Clean
kp clusterbuilder patch demo-builder --stack old
kubectl delete -f image.yaml
kubectl delete -f cnb-image.yaml

# Delete Harbor images


# Video
https://www.youtube.com/watch?v=SK6e_ZatOaw => 3.50