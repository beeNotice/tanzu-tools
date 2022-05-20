# KP configuration
# https://tanzucommunityedition.io/docs/v0.11/package-readme-kpack-0.5.2/
docker login $HARBOR_URL -u fma

# Deploy App for demo purpose
k apply -f k8s/
k get pods -n tanzu-simple

# Preprare env
# https://hub.docker.com/r/paketobuildpacks/build/
k apply -f kpack/
k get Image -n cnb-nodejs

kp build logs cnb-nodejs -n cnb-nodejs
kp build list cnb-nodejs -n cnb-nodejs

# Image description
cat image.yaml
kubectl apply -f image.yaml

kp build logs tanzu-simple -n build
kp build status tanzu-simple -n build

# Access App
k get pods -n tanzu-simple
http://tanzu-tce-fmartin.francecentral.cloudapp.azure.com

# Patch
kp clusterbuilder patch demo-builder --stack old
kp clusterbuilder patch demo-builder --stack new

kp build list -n build

# Check
k get clusterstore
k get clusterstack
k get clusterbuilder
