###########################################
# Cloud Native Buildpacks
###########################################
# Show code
cat $TAP_FILES_PATH/data/image.yaml

# Build
k apply -f $TAP_FILES_PATH/data/image.yaml

# Current Status
kp build logs tanzu-simple -n dev
kp build status tanzu-simple -n dev

# Same with Node
cat $TAP_FILES_PATH/data/image-node.yaml
k apply -f $TAP_FILES_PATH/data/image-node.yaml
kp build logs cnb-nodejs -n dev

# Patch
kp build list -n dev
kp clusterbuilder patch default --stack base
kp build list -n dev

###########################################
# Workload
###########################################
# App Deployment
cat $TANZU_APP_FILES_PATH/config/workload.yaml
k apply -f $TANZU_APP_FILES_PATH/config/workload.yaml

# Follow
tanzu apps workload get tanzu-app-deploy -n dev

k describe gitrepositories.source.toolkit.fluxcd.io/tanzu-app-deploy -n dev
k describe images.kpack.io/tanzu-app-deploy -n dev

https://tanzu-app-deploy.dev.tanzu.beenotice.eu/
https://github.com/beeNotice/tanzu-app-deploy/tree/main

###########################################
# Clean
###########################################
k delete -f $TAP_FILES_PATH/data/image.yaml
k delete -f $TAP_FILES_PATH/data/image-node.yaml
k delete -f $TANZU_APP_FILES_PATH/config/workload.yaml

kp clusterbuilder patch default --stack old
