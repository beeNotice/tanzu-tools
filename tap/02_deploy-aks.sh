# https://github.com/Tanzu-Solutions-Engineering/se-tap-bootcamps/tree/main/tap-up-and-running-bootcamp
# https://github.com/kennism/homelab/tree/main/tap

# Azure login
az login

# Set your default subscription
az account list --output table
az account set --subscription "subscription-id"
az account show --output table

# Terraform
cd $TAP_FILES_PATH/aks
terraform init
terraform apply

# Login to AKS
az aks get-credentials --resource-group=rg-tanzu-tap --name=aks-tanzu-tap

# Tanzu CLI
# https://network.tanzu.vmware.com/products/tanzu-application-platform/
mkdir $HOME/tanzu
tar -xvf $TANZU_TOOLS_FILES_PATH/binaries/tanzu-framework-linux-amd64.tar -C $HOME/tanzu
export TANZU_CLI_NO_INIT=true
cd $HOME/tanzu
sudo install cli/core/v0.10.0/tanzu-core-linux_amd64 /usr/local/bin/tanzu
tanzu plugin install --local cli all

# Check
tanzu version
tanzu plugin list

# Cluste essentials
mkdir $HOME/tanzu-cluster-essentials
tar -xvf $TANZU_TOOLS_FILES_PATH/binaries/tanzu-cluster-essentials-linux-amd64-1.0.0.tgz -C $HOME/tanzu-cluster-essentials

# Add the Tanzu Application Platform package repository
export INSTALL_BUNDLE=registry.tanzu.vmware.com/tanzu-cluster-essentials/cluster-essentials-bundle@sha256:82dfaf70656b54dcba0d4def85ccae1578ff27054e7533d08320244af7fb0343
export INSTALL_REGISTRY_HOSTNAME=registry.tanzu.vmware.com
export INSTALL_REGISTRY_USERNAME=$TANZU_NET_USER
export INSTALL_REGISTRY_PASSWORD=$TANZU_NET_PASSWORD
cd $HOME/tanzu-cluster-essentials
./install.sh
cd

kubectl create ns tap-install

# Prepare Data
tanzu secret registry add tap-registry \
  --username ${INSTALL_REGISTRY_USERNAME} \
  --password ${INSTALL_REGISTRY_PASSWORD} \
  --server ${INSTALL_REGISTRY_HOSTNAME} \
  --export-to-all-namespaces \
  --yes \
  --namespace tap-install

tanzu package repository add tanzu-tap-repository \
  --url registry.tanzu.vmware.com/tanzu-application-platform/tap-packages:$TAP_VERSION \
  --namespace tap-install

# Check
tanzu package repository get tanzu-tap-repository --namespace tap-install
tanzu package available list --namespace tap-install

# Deploy TAP
tanzu package install tap \
     -p tap.tanzu.vmware.com \
     -v $TAP_VERSION \
     --values-file $TAP_FILES_PATH/data/tap-values-full.yml \
     -n tap-install

# Check
tanzu package installed list -A

# Set up developer namespaces to use installed packages
# https://docs.vmware.com/en/Tanzu-Application-Platform/1.0/tap/GUID-install-components.html#setup
tanzu secret registry add registry-credentials \
--server https://harbor.withtanzu.com \
--username $HARBOR_USER \
--password $HARBOR_PASS \
--namespace default

cat <<EOF | kubectl -n dev apply -f -

apiVersion: v1
kind: Secret
metadata:
  name: tap-registry
  annotations:
    secretgen.carvel.dev/image-pull-secret: ""
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: e30K

---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: default
secrets:
  - name: registry-credentials
imagePullSecrets:
  - name: registry-credentials
  - name: tap-registry

---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: default
rules:
- apiGroups: [source.toolkit.fluxcd.io]
  resources: [gitrepositories]
  verbs: ['*']
- apiGroups: [source.apps.tanzu.vmware.com]
  resources: [imagerepositories]
  verbs: ['*']
- apiGroups: [carto.run]
  resources: [deliverables, runnables]
  verbs: ['*']
- apiGroups: [kpack.io]
  resources: [images]
  verbs: ['*']
- apiGroups: [conventions.apps.tanzu.vmware.com]
  resources: [podintents]
  verbs: ['*']
- apiGroups: [""]
  resources: ['configmaps']
  verbs: ['*']
- apiGroups: [""]
  resources: ['pods']
  verbs: ['list']
- apiGroups: [tekton.dev]
  resources: [taskruns, pipelineruns]
  verbs: ['*']
- apiGroups: [tekton.dev]
  resources: [pipelines]
  verbs: ['list']
- apiGroups: [kappctrl.k14s.io]
  resources: [apps]
  verbs: ['*']
- apiGroups: [serving.knative.dev]
  resources: ['services']
  verbs: ['*']
- apiGroups: [servicebinding.io]
  resources: ['servicebindings']
  verbs: ['*']
- apiGroups: [services.apps.tanzu.vmware.com]
  resources: ['resourceclaims']
  verbs: ['*']
- apiGroups: [scanning.apps.tanzu.vmware.com]
  resources: ['imagescans', 'sourcescans']
  verbs: ['*']

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: default
subjects:
  - kind: ServiceAccount
    name: default

EOF

# Access Apps
kubectl get service envoy -n tanzu-system-ingress
# Create DNS entry to this IP or add it to the host C:\Windows\System32\drivers\etc
http://tap-gui.fmartin.tech/

# Expose API Portal
k apply -f $TAP_FILES_PATH/data/api-portal-httpproxy.yaml
k get httpproxy -A


# Prepare Service Binding
# https://docs.vmware.com/en/VMware-Tanzu-SQL-with-Postgres-for-Kubernetes/1.5/tanzu-postgres-k8s/GUID-install-operator.html#create-service-accounts
export HELM_EXPERIMENTAL_OCI=1
helm registry login registry.pivotal.io \
       --username=$TANZU_NET_USER \
       --password=$TANZU_NET_PASSWORD

helm pull oci://registry.pivotal.io/tanzu-sql-postgres/postgres-operator-chart --version v1.5.0 --untar --untardir /tmp

k create ns postgresql
kubectl create secret docker-registry regsecret \
    --docker-server=https://registry.pivotal.io/ \
    --docker-username=$TANZU_NET_USER \
    --docker-password=$TANZU_NET_PASSWORD \
    --namespace=postgresql

helm install my-postgres-operator /tmp/postgres-operator/ \
  --namespace=postgresql \
  --wait

# Check
kubectl get all --selector app=postgres-operator -n postgresql
k get pod -n postgresql

# Deploy Postgresql
# https://docs.vmware.com/en/VMware-Tanzu-SQL-with-Postgres-for-Kubernetes/1.5/tanzu-postgres-k8s/GUID-create-delete-postgres.html
k apply -f $TAP_FILES_PATH/data/postgresql.yaml
k get Postgres -n postgresql
k get pods -n postgresql

# Connect
kubectl exec -it postgres-tanzu-app-0 -n postgresql -- bash -c "psql"
\l
\c postgres-tanzu-app
select * from choice;

# Service Binding
# https://docs.vmware.com/en/VMware-Tanzu-SQL-with-Postgres-for-Kubernetes/1.5/tanzu-postgres-k8s/GUID-creating-service-bindings.html
kubectl apply -f $TAP_FILES_PATH/data/resource-claims-postgres.yaml
kubectl apply -f $TAP_FILES_PATH/data/postgres-cross-namespace.yaml

# Check service Binding
# https://docs.vmware.com/en/VMware-Tanzu-SQL-with-Postgres-for-Kubernetes/1.5/tanzu-postgres-k8s/GUID-creating-service-bindings.html#verify-a-tap-workload-service-binding
dbname=$(kubectl get secrets postgres-tanzu-app-app-user-db-secret -n postgresql -o jsonpath='{.data.database}' | base64 -d)
username=$(kubectl get secrets postgres-tanzu-app-app-user-db-secret -n postgresql -o jsonpath='{.data.username}' | base64 -d)
password=$(kubectl get secrets postgres-tanzu-app-app-user-db-secret -n postgresql -o jsonpath='{.data.password}' | base64 -d)

host=$(kubectl get secrets postgres-tanzu-app-app-user-db-secret -n postgresql -o jsonpath='{.data.host}' | base64 -d)
port=$(kubectl get secrets postgres-tanzu-app-app-user-db-secret -n postgresql -o jsonpath='{.data.port}' | base64 -d)

# Start / Stop AKS
az aks start --resource-group rg-tanzu-tap --name aks-tanzu-tap
az aks stop --resource-group rg-tanzu-tap --name aks-tanzu-tap

# Update tap
tanzu package installed update tap \
     -p tap.tanzu.vmware.com \
     -v $TAP_VERSION \
     --values-file $TAP_FILES_PATH/data/tap-values-full.yml \
     -n tap-install

# TBS Configuration
kp clusterstack create old \
--build-image registry.pivotal.io/tanzu-base-bionic-stack/build@sha256:46fcb761f233e134a92b780ac10236cc1c2e6b19d590b2b3b4d285d3f8fd9ecf \
--run-image registry.pivotal.io/tanzu-base-bionic-stack/run@sha256:b6b1612ab2dfa294514fff2750e8d724287f81e89d5e91209dbdd562ed7f7daf

# SE Installation
# https://github.com/Tanzu-Solutions-Engineering/se-tap-bootcamps/tree/main/tap-up-and-running-bootcamp

export CLUSTER_NAME=tap-demo
az aks create --resource-group ${CLUSTER_NAME} --name ${CLUSTER_NAME} --node-count 2 --enable-addons monitoring --node-vm-size Standard_DS3_v2 --node-osdisk-size 500 --enable-pod-security-policy
az aks delete --name ${CLUSTER_NAME} --resource-group ${CLUSTER_NAME}