###########################################
# Intro / Context
###########################################
PPT | Introduction

###########################################
# Developer experience
###########################################
# Explore
http://tap-gui.tanzu.fmartin.tech/catalog?filters%5Bkind%5D=component&filters%5Buser%5D=owned

# Accelerators
http://tap-gui.tanzu.fmartin.tech/create?filters%5Bkind%5D=template&filters%5Buser%5D=all

# Develop App - Eclipse

# App Deployment
tanzu apps workload create -f $TANZU_APP_FILES_PATH/config/workload.yaml -y

# Access App & Infos
http://tap-gui.tanzu.fmartin.tech/catalog?filters%5Bkind%5D=component&filters%5Buser%5D=owned
- Status
- Logs
- Live View

# Access APIs
http://tap-gui.tanzu.fmartin.tech/api-docs?filters%5Bkind%5D=api&filters%5Buser%5D=all
http://api-portal.tanzu.fmartin.tech/

http://tanzu-app-deploy.dev.tanzu.fmartin.tech/v3/api-docs
http://tanzu-app-deploy.dev.tanzu.fmartin.tech/swagger-ui/index.html

# Cloud Native Buildpacks
http://tap-gui.tanzu.fmartin.tech/supply-chain

# Patch
kp clusterbuilder patch default --stack base

# Current Status
kp build list -n dev
kp build logs tanzu-app-deploy -n dev
kp build status tanzu-app-deploy -n dev

# Deployment to Prod
k apply -f $TANZU_APP_FILES_PATH/config/deliverable.yaml
k get pods -n prod

http://tanzu-app-deploy.prod.tanzu.fmartin.tech/

###########################################
# Knative - Autoscaling
###########################################
# Prime
http://tanzu-app-deploy.prod.tanzu.fmartin.tech/prime/900003883

# Run performance
watch kubectl get pods --selector=app.kubernetes.io/component=run -n prod

###########################################
# Clean
###########################################
k delete -f $TANZU_APP_FILES_PATH/config/deliverable.yaml
k delete -f $TANZU_APP_FILES_PATH/config/workload.yaml

kp clusterbuilder patch default --stack old

