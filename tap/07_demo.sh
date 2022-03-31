###########################################
# Intro / Context
###########################################
https://tanzu.vmware.com/application-platform
https://portal.azure.com/#home

###########################################
# Start Project
###########################################
# Learning
https://portal.end2end.link/

# Accelerators
http://tap-gui.tanzu.fmartin.tech/create?filters%5Bkind%5D=template&filters%5Buser%5D=all

###########################################
# App Deployment
###########################################
tanzu apps workload create -f $TANZU_APP_FILES_PATH/config/workload.yaml
# Follow logs
tanzu apps workload tail tanzu-app-deploy -n dev --since 1m

# Supply chain details
PPT | Deploying an App Today
https://cartographer.sh/
PPT | TAP Supply Chain Patterns

# Supply Chain Configuration
tanzu apps cluster-supply-chain list

https://github.com/vmware-tanzu/cartographer/blob/main/examples/basic-sc/developer/workload.yaml
https://github.com/vmware-tanzu/cartographer/blob/main/examples/basic-sc/app-operator/supply-chain.yaml
https://github.com/vmware-tanzu/cartographer/blob/main/examples/shared/app-operator/git-source-template.yaml
https://github.com/vmware-tanzu/cartographer/blob/main/examples/shared/app-operator/kpack-image-template.yaml

https://fluxcd.io/docs/components/source/gitrepositories/
https://github.com/pivotal/kpack/blob/main/docs/image.md#sample-image-resource-with-a-git-source

# Follow Workload
tanzu apps workload get tanzu-app-deploy -n dev

# Access App & Infos
http://tanzu-app-deploy-dev.tanzu.fmartin.tech/
http://tap-gui.tanzu.fmartin.tech/catalog?filters%5Bkind%5D=component&filters%5Buser%5D=owned
http://tap-gui.tanzu.fmartin.tech/app-live-view/

http://tanzu-app-deploy-dev.tanzu.fmartin.tech/v3/api-docs
http://api-portal.tanzu.fmartin.tech/

###########################################
# Pipeline
###########################################

# Present Pipeline
PPT | Out of the Box Sample – Outer Loop
https://docs.vmware.com/en/Tanzu-Application-Platform/1.0/tap/GUID-getting-started.html#1-ootb-basic-default-17
https://docs.vmware.com/en/Tanzu-Application-Platform/1.0/tap/GUID-getting-started.html#3-ootb-testingscanning-19


###########################################
# Test
###########################################
https://github.com/beeNotice/tanzu-tools/blob/main/tap/data/tekton-pipeline.yaml

###########################################
# Build
###########################################
# Follow TBS
https://buildpacks.io/
https://docs.vmware.com/en/VMware-Tanzu-Buildpacks/index.html

kp build list -n dev
kp build logs tanzu-app-deploy -n dev
kp image status tanzu-app-deploy -n dev

###########################################
# Security
###########################################
https://github.com/beeNotice/tanzu-tools/blob/main/tap/data/scan-policy.yaml

# Security results
export METADATA_STORE_ACCESS_TOKEN=$(kubectl get secrets -n metadata-store -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='metadata-store-read-write-client')].data.token}" | base64 -d)
insight health

# Source
kubectl get sourcescans -n dev
insight source get \
  --repo  tanzu-app \
  --commit 1fd6891cc196c1fb054646e6bec7ed3f19ed9a2a \
  --org beeNotice

# Image
k get imagescans -n dev
insight image get --digest sha256:40ab2961b3946133dc91d2e85d49d3474155edda21df00458bc237c048cf18ec

# Scan with Trivy
https://harbor.withtanzu.com/harbor/projects/9/repositories

# Search for a CVE
insight vulnerabilities images --cveid CVE-2022-0778

###########################################
# Patch image
###########################################
http://tanzu-app-deploy-dev.tanzu.fmartin.tech/actuator/info

kp clusterbuilder patch default --stack base
kp clusterbuilder patch default --stack old

kp build list -n dev
kp build logs tanzu-app-deploy -n dev

###########################################
# Delivery
###########################################
https://github.com/vmware-tanzu/cartographer/blob/main/examples/gitwriter-sc/app-operator/config-service.yaml
https://github.com/beeNotice/tanzu-app-deploy


###########################################
# Deployment
###########################################
PPT | TAP Supply Chain Patterns

https://github.com/beeNotice/tanzu-app/blob/main/config/deliverable.yaml
https://github.com/vmware-tanzu/cartographer/blob/main/examples/basic-delivery/app-operator/deliverable.yaml
https://github.com/vmware-tanzu/cartographer/blob/main/examples/basic-delivery/app-operator/delivery.yaml
https://github.com/vmware-tanzu/cartographer/blob/main/examples/basic-delivery/app-operator/source-git-repository.yaml


k apply -f $TANZU_APP_FILES_PATH/config/deliverable.yaml
k get deliverable -n prod
k get pods -n prod

###########################################
# Knative
###########################################
# https://knative.dev/docs/serving/autoscaling/autoscaler-types/#global-settings


###########################################
# Clean
###########################################
k delete -f $TANZU_APP_FILES_PATH/config/deliverable.yaml
tanzu apps workload delete -f $TANZU_APP_FILES_PATH/config/workload.yaml