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

kp clusterbuilder patch demo-builder --stack old
kp clusterbuilder patch demo-builder --stack new

kp build list -n build

https://harbor.withtanzu.com/harbor/projects/9/repositories/tanzu-simple
http://tanzu-tce-fmartin.francecentral.cloudapp.azure.com/actuator/info

https://harbor.withtanzu.com/harbor/projects/9/repositories/cnb-nodejs

