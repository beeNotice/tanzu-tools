# Check prerequisites
# On TKGs 
# https://docs.vmware.com/en/Tanzu-Build-Service/1.3/vmware-tanzu-build-service-v13/GUID-installing.html
# https://docs.vmware.com/en/VMware-vSphere/7.0/vmware-vsphere-with-tanzu/GUID-B1034373-8C38-4FE2-9517-345BF7271A1E.html#cluster-with-separate-disks-and-storage-parameters-1

# Docker login
docker login -u fmartin@vmware.com registry.pivotal.io
docker login -u fma harbor.withtanzu.com

# Create Harbor secrets (namespace has to be the same that will be used for the kp image create)
k create ns $BUILD_SERVICE_NAMESPACE
kp secret create harbor-creds --registry harbor.withtanzu.com --registry-user fma --namespace $BUILD_SERVICE_NAMESPACE

# Relocate image
imgpkg copy -b "registry.pivotal.io/build-service/bundle:1.2.2" --to-repo harbor.withtanzu.com/fmartin/build-service/

# Deploy
imgpkg pull -b "harbor.withtanzu.com/fmartin/build-service:1.2.2" -o /tmp/bundle
ytt -f /tmp/bundle/values.yaml \
    -f /tmp/bundle/config/ \
    -v docker_repository='harbor.withtanzu.com/fmartin/build-service' \
    -v docker_username="$HARBOR_USER" \
    -v docker_password="$HARBOR_PASS" \
    | kbld -f /tmp/bundle/.imgpkg/images.yml -f- \
    | kapp deploy -a tanzu-build-service -f- -y

# Import Stacks & Builders
# https://network.tanzu.vmware.com/products/tbs-dependencies#/releases/959846
kp import -f $TBS_FILES_PATH/data/descriptor-100.0.212.yaml

# Demo stack
kp clusterstack create old \
--build-image registry.pivotal.io/tanzu-base-bionic-stack/build@sha256:46fcb761f233e134a92b780ac10236cc1c2e6b19d590b2b3b4d285d3f8fd9ecf \
--run-image registry.pivotal.io/tanzu-base-bionic-stack/run@sha256:b6b1612ab2dfa294514fff2750e8d724287f81e89d5e91209dbdd562ed7f7daf

kp clusterstack create new \
--build-image registry.pivotal.io/tanzu-base-bionic-stack/build@sha256:ce0e5d29c55f7232195dc114c8643084c6e3f32d7c03a4aaa6175b12a984b5db \
--run-image registry.pivotal.io/tanzu-base-bionic-stack/run@sha256:53e900797c8da768c2a254aca3ec1f3f4b5afd131d62787323e4f0374a6e7ad0

# Check
k get pods -n build-service

[source, sh]
.Create Image
----
# Building pods will be deployed in the namespace
k create ns build-service-builds
kp image create tanzu-app \
  --tag harbor.withtanzu.com/fmartin/tanzu-app \
  --wait \
  --git https://github.com/beeNotice/tanzu-app.git \
  --git-revision main

# Kubernetes CRD
k get images.kpack.io tanzu-app -n build-service-builds -o yaml
----

