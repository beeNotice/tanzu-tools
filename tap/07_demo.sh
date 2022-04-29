###########################################
# Intro / Context
###########################################
https://tanzu.vmware.com/application-platform
https://portal.azure.com/#home
PPT | Deploying an App Today

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

# Follow Workload
tanzu apps workload get tanzu-app-deploy -n dev

# Access App & Infos
http://tanzu-app-deploy-dev.tanzu.fmartin.tech/
http://tap-gui.tanzu.fmartin.tech/catalog?filters%5Bkind%5D=component&filters%5Buser%5D=owned
http://tap-gui.tanzu.fmartin.tech/app-live-view/

# Access APIs
http://tanzu-app-deploy-dev.tanzu.fmartin.tech/v3/api-docs
http://api-portal.tanzu.fmartin.tech/

###########################################
# Supply Chain
###########################################
# Supply chain details
# C:\Users\fmartin\OneDrive - VMware, Inc\Meetings\Fabien\VMware Tanzu - TAP - fmartin.pptx
PPT | TAP Supply Chain Patterns

# Supply Chain Configuration
tanzu apps cluster-supply-chain list

https://github.com/vmware-tanzu/cartographer/blob/main/examples/basic-sc/developer/workload.yaml
https://github.com/vmware-tanzu/cartographer/blob/main/examples/basic-sc/app-operator/supply-chain.yaml
https://github.com/vmware-tanzu/cartographer/blob/main/examples/shared/app-operator/git-source-template.yaml
https://github.com/vmware-tanzu/cartographer/blob/main/examples/shared/app-operator/kpack-image-template.yaml

https://fluxcd.io/docs/components/source/gitrepositories/
https://github.com/pivotal/kpack/blob/main/docs/image.md#sample-image-resource-with-a-git-source

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
insight image get --digest sha256:57fa7a3ad4a0f138763118e1b51a359c2923bd870f8db6e4d640cb6509bbf743

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

# Deep dive only if requested (the intent is included in the config-template)
k get ClusterConfigTemplate convention-template -o yaml

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
# Knative - Autoscaling
###########################################
# https://knative.dev/docs/serving/configuration/deployment/#example-config-deployment-configmap
kubectl get configmap -n knative-serving config-deployment -o yaml

https://tanzu.vmware.com/developer/guides/knative-serving-wi/
https://github.com/beeNotice/tanzu-app-deploy/blob/main/config/delivery.yml

kn service list -n prod
k get service.serving.knative.dev,route.serving.knative.dev,configuration.serving.knative.dev,revision.serving.knative.dev -n prod

# Run performance
watch kubectl get pods --selector=app.kubernetes.io/component=run -n prod

###########################################
# Knative - # Native App - WIP
###########################################
https://github.com/beeNotice/tanzu-app/commit/a42fba302fd4b1afecd67895bd17344068b58406

k logs tanzu-app-deploy-00003-deployment-7ccb67dd5d-24hbt -n prod workload
=> Started TanzuAppApplication in 13.851 seconds

# Update deliverable to native branch
k delete -f $TANZU_APP_FILES_PATH/config/deliverable.yaml
k apply -f $TANZU_APP_FILES_PATH/config/deliverable.yaml

watch kubectl get pods -n prod
kubectl get pods -n prod

k logs tanzu-app-deploy-00003-deployment-7ccb67dd5d-24hbt -n prod workload
=> Started TanzuAppApplication in 0.614 seconds

###########################################
# Clean
###########################################
k delete -f $TANZU_APP_FILES_PATH/config/deliverable.yaml
tanzu apps workload delete -f $TANZU_APP_FILES_PATH/config/workload.yaml