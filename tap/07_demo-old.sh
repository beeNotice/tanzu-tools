###########################################
# Prerequisites
###########################################

# EKS
tanzu service class-claim create postgresql-claim --class postgresql-unmanaged --parameter storageGB=5 -n dev

###########################################
# Intro / Context
###########################################
PPT | Introduction

###########################################
# Developer experience
###########################################
# Explore
http://tap-gui.tanzu.beenotice.eu/catalog?filters%5Bkind%5D=component&filters%5Buser%5D=owned

# Accelerators
http://tap-gui.tanzu.beenotice.eu/create?filters%5Bkind%5D=template&filters%5Buser%5D=all

# App Deployment
tanzu apps workload create -f $TANZU_APP_FILES_PATH/config/workload.yaml -y

# Follow
tanzu apps workload tail tanzu-app-deploy -n dev --since 1m
tanzu apps workload get tanzu-app-deploy -n dev

# Access App & Infos
http://tap-gui.tanzu.beenotice.eu/catalog?filters%5Bkind%5D=component&filters%5Buser%5D=owned
- Status
- Logs
- Live View

# Access APIs
http://tap-gui.tanzu.beenotice.eu/api-docs?filters%5Bkind%5D=api&filters%5Buser%5D=all
http://api-portal.tanzu.beenotice.eu/
- Portal

###########################################
# Supply Chain
###########################################
# Supply Chain
tanzu apps workload get tanzu-app-deploy --namespace dev

# Supply Chain Configuration
tanzu apps cluster-supply-chain list
tanzu apps cluster-supply-chain get source-test-scan-to-url

http://tap-gui.tanzu.beenotice.eu/supply-chain
  - Follow
  - Security

###########################################
# Cloud Native Buildpacks
###########################################
https://buildpacks.io/

# Current Status
kp build list -n dev
kp build logs tanzu-app-deploy -n dev
kp build status tanzu-app-deploy -n dev

# Patch
k get ClusterBuilder default -o yaml
kp clusterstack list
kp clusterbuilder patch default --stack base

# Check as above
kp clusterstack list

###########################################
# Deployment to EKS
###########################################
https://github.com/beeNotice/tanzu-app-deploy

# https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.5/tap/multicluster-getting-started.html
k apply -f $TANZU_APP_FILES_PATH/config/deliverable.yaml
k get pods -n dev

http://tanzu-app-deploy.prod.tanzu.beenotice.eu/

PPT | Summary
  - TBS
  - Path to Production
  - Deliverable

###########################################
# Knative - Autoscaling
###########################################
# Prime
http://tanzu-app-deploy.prod.tanzu.beenotice.eu/prime/900003883

# Run performance
watch kubectl get pods --selector=app.kubernetes.io/component=run -n prod

###########################################
# Clean
###########################################
k delete -f $TANZU_APP_FILES_PATH/config/deliverable.yaml
k delete -f $TANZU_APP_FILES_PATH/config/workload.yaml

k delete -f $TAP_FILES_PATH/data/postgresql-gcp.yaml

kp clusterbuilder patch default --stack old
