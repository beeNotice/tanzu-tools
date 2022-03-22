# GUI
https://portal.end2end.link/
https://api-portal.tap-gcp.tanzu.club/apis
http://tap-gui.fmartin.tech/create?filters%5Bkind%5D=template&filters%5Buser%5D=all
Accelerators > Spring Sensors > View Repository > accelerator.yaml

http://tanzu-app-deploy.default.fmartin.tech/
http://tap-gui.fmartin.tech/catalog?filters%5Bkind%5D=component&filters%5Buser%5D=owned
http://tap-gui.fmartin.tech/app-live-view/

# Dev view
# Create workload
k apply -f $TANZU_APP_FILES_PATH/config/workload.yaml

# Follow logs
tanzu apps workload tail tanzu-app-deploy -n dev --since 1m

# Follow Workload
tanzu apps workload get tanzu-app-deploy -n dev

# Follow TBS
kp build list -n dev
kp build logs tanzu-app-deploy -n dev

# Supply chain details
k get Pipeline -o yaml
k get ScanPolicy -o yaml
kubectl get scantemplates


# Security results
export METADATA_STORE_ACCESS_TOKEN=$(kubectl get secrets -n metadata-store -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='metadata-store-read-write-client')].data.token}" | base64 -d)

# Source
# https://github.com/beeNotice/tanzu-app
insight source get \
  --repo  tanzu-app \
  --commit 36efc1ab7650cf815e1ecb2d4ffcababd7676db7 \
  --org beeNotice

kp build list -n dev
insight image get --digest sha256:01176ef73c032ca7f8d2369a9d5efde6a09fe1a96741c8c988aaf0ee38195303

# TBS Demo
https://buildpacks.io/

kp clusterbuilder patch default --stack base
kp clusterbuilder patch default --stack old

kp build list -n dev
kp build logs tanzu-app-deploy -n dev

Harbor / Scan

# Déploiement
https://github.com/beeNotice/tanzu-app-deploy


# Pipeline view
# Highlight matching with the workloads
tanzu apps cluster-supply-chain list

# Service Binding views
http://tanzu-app-deploy.dev.fmartin.tech/actuator/env > kubernetesServiceBindingSpecific
