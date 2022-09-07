git clone git@github.com:beeNotice/tanzu-app.git
cd $TANZU_APP_FILES_PATH

git checkout -b native
git pull origin native

./mvnw spring-boot:build-image

# Test


# Deploy image
docker login $TAP_REGISTRY_HOSTNAME -u $TAP_REGISTRY_USERNAME
docker tag tanzu-app:0.0.1-SNAPSHOT $TAP_REGISTRY_HOSTNAME/fmartin/tanzu-app-deploy-native/tanzu-app:0.0.1-SNAPSHOT
docker image list
docker push $TAP_REGISTRY_HOSTNAME/fmartin/tanzu-app-deploy-native/tanzu-app:0.0.1-SNAPSHOT


# https://knative.dev/docs/serving/configuration/deployment/#example-config-deployment-configmap
kubectl get configmap -n knative-serving config-deployment -o yaml


kn service list -n prod
k get service.serving.knative.dev,route.serving.knative.dev,configuration.serving.knative.dev,revision.serving.knative.dev -n prod