# GUI
https://portal.end2end.link/
https://api-portal.tap-gcp.tanzu.club/apis
http://tap-gui.fmartin.tech/create?filters%5Bkind%5D=template&filters%5Buser%5D=all
Accelerators > Spring Sensors > View Repository > accelerator.yaml

http://tanzu-app-deploy.default.fmartin.tech/
http://tap-gui.fmartin.tech/catalog?filters%5Bkind%5D=component&filters%5Buser%5D=owned
http://tap-gui.fmartin.tech/app-live-view/

# Create workload
k apply -f $TANZU_APP_FILES_PATH/config/workload.yaml

# Follow logs
tanzu apps workload tail tanzu-app-deploy --since 1m

# Follow Workload
tanzu apps workload get tanzu-app-deploy

# Supply chain details
k get Pipeline -o yaml
k get ScanPolicy -o yaml
kubectl get scantemplates

# Security results
export METADATA_STORE_ACCESS_TOKEN=$(kubectl get secrets -n metadata-store -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='metadata-store-read-write-client')].data.token}" | base64 -d)

# Source
insight source get \
  --repo  tanzu-app \
  --commit 9ca244c13367650ee01e6f0c76ae0ea213d58b93 \
  --org beeNotice

kp build list
insight image get --digest sha256:25078eafd04cb1983c500e0ee0ede9a59ca31def5866819095e46658812d1f9b

# TBS Demo
https://buildpacks.io/

kp clusterbuilder patch default --stack base
kp clusterbuilder patch default --stack old

kp build list
kp build logs tanzu-app-deploy

Harbor / Scan