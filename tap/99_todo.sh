# TODO
- Refactoring catalog-info
- Produce App documentation & links

- Blue / Green
- Existing/Legacy applications
- Deploy production on EKS

- Navigate APIs
- Offer API consummer

- Auto load APIs in the portal
Define the Cluster name in the Workload portal

Add Service Binding demo in the Actuator


Prerequisites
Lombok

https://vmware.slack.com/archives/C02D60T1ZDJ/p1656711397305319

sh $TAP_FILES_PATH/script/create-additional-dev-space.sh spring-petclinic

k apply -f /mnt/c/Dev/workspaces/spring-petclinic-tanzu/spring-petclinic-config-server/config/workload.yaml
k apply -f /mnt/c/Dev/workspaces/spring-petclinic-tanzu/spring-petclinic-discovery-server/config/workload.yaml


tanzu apps workload get spring-petclinic-discovery-server -n spring-petclinic
kp build logs spring-petclinic-discovery-server -n spring-petclinic

kubectl run busybox --image=busybox --rm -it --restart=Never -- wget -O- http://spring-petclinic-config-server.spring-petclinic.svc.cluster.local


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







________________________________________________________________________________
k get resourceclaim
k get serviceBinding

cat <<EOF | kubectl apply - f- 
apiVersion: v1
kind: Secret
metadata:
  name: vac-db-binding-compatible
type: Opaque
stringData:
  type: postgresql
  provider: vac
  host: my-postgresql
  port: "5432"
  database: "music"
  username: "postgres"
  password: "postgres"
EOF

tanzu service claim create vac-db-claim-compatible \
  --resource-name vac-db-binding-compatible \
  --resource-kind Secret \
  --resource-api-version v1
  
https://github.com/tsalm-pivotal/spring-cloud-demo-tap/blob/main/tap/workload-order-service.yaml
  serviceClaims:
  - name: db
    ref:
      apiVersion: services.apps.tanzu.vmware.com/v1alpha1
      kind: ResourceClaim
      name: vac-db-binding-compatible

➜  VAC cat clusterrole.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: stk-secret-reader
  labels:
    servicebinding.io/controller: "true"
rules:
- apiGroups:
  - ""
  resources:
  - secrets
  verbs:
  - get
  - list
  - watch

https://docs.vmware.com/en/Services-Toolkit-for-VMware-Tanzu-Application-Platform/0.8/svc-tlk/GUID-usecases-direct_secret_references.html


