# Prepare Service Binding
# https://docs.vmware.com/en/VMware-Tanzu-SQL-with-Postgres-for-Kubernetes/1.8/tanzu-postgres-k8s/GUID-install-operator.html#installing-using-the-tanzu-cli
TDS_VERSION=1.1.0
imgpkg copy -b registry.tanzu.vmware.com/packages-for-vmware-tanzu-data-services/tds-packages:${TDS_VERSION} \
     --to-repo $TAP_REGISTRY_HOSTNAME/fmartin/tds-packages

# List secrets
tanzu secret registry list -n tanzu-data

# Create secret
tanzu secret registry add tap-registry -n tanzu-data \
    --username $TAP_REGISTRY_USERNAME \
    --password $TAP_REGISTRY_PASSWORD \
    --server $TAP_REGISTRY_HOSTNAME

# Add repository
kubectl create ns tanzu-data
tanzu package repository add tanzu-data-services-repository \
  --url $TAP_REGISTRY_HOSTNAME/fmartin/tds-packages:${TDS_VERSION} \
  --namespace tanzu-data

# Check
tanzu package available list -A

# Install
tanzu package install postgres \
  --package-name postgres-operator.sql.tanzu.vmware.com \
  --version 1.8.0 \
  --namespace tanzu-data \
  -f $TAP_FILES_PATH/data/postgresql/tds.yaml

# Check
tanzu package installed list -n tanzu-data
kubectl get all --selector app=postgres-operator -n tanzu-data

# Service Binding
# https://docs.vmware.com/en/VMware-Tanzu-SQL-with-Postgres-for-Kubernetes/1.8/tanzu-postgres-k8s/GUID-creating-service-bindings.html
kubectl apply -f $TAP_FILES_PATH/data/postgresql/resource-claims-postgres.yaml

#kubectl apply -f $TAP_FILES_PATH/data/postgres-cross-namespace.yaml => Don't use anymore, on DB per ns

# Deploy Postgresql - Update ns for dev & prod
# https://docs.vmware.com/en/VMware-Tanzu-SQL-with-Postgres-for-Kubernetes/1.8/tanzu-postgres-k8s/GUID-create-delete-postgres.html
# This is done using the create-additional-dev-space.sh script
# ytt -f $TAP_FILES_PATH/data/postgresql/postgresql.yaml -v namespace=dev | kubectl apply -f-
# Checks
k get Postgres -n dev
k get pods -n dev

# Connect & Update production Data
kubectl exec -it postgres-tanzu-app-0 -n dev -- bash -c "psql"
\l
\c postgres-tanzu-app


# Check service Binding
# https://docs.vmware.com/en/VMware-Tanzu-SQL-with-Postgres-for-Kubernetes/1.5/tanzu-postgres-k8s/GUID-creating-service-bindings.html#verify-a-tap-workload-service-binding
dbname=$(kubectl get secrets postgres-tanzu-app-app-user-db-secret -n prod -o jsonpath='{.data.database}' | base64 -d)
username=$(kubectl get secrets postgres-tanzu-app-app-user-db-secret -n prod -o jsonpath='{.data.username}' | base64 -d)
password=$(kubectl get secrets postgres-tanzu-app-app-user-db-secret -n prod -o jsonpath='{.data.password}' | base64 -d)

host=$(kubectl get secrets postgres-tanzu-app-app-user-db-secret -n prod -o jsonpath='{.data.host}' | base64 -d)
port=$(kubectl get secrets postgres-tanzu-app-app-user-db-secret -n prod -o jsonpath='{.data.port}' | base64 -d)

# To showcase the configuration demo, update the configuration values in the production environement
kubectl exec -it postgres-tanzu-app-0 -n prod -- bash -c "psql"
\c postgres-tanzu-app
UPDATE config set val='PROD' where name = 'ENV';
UPDATE config set val='#993333' where name = 'COLOR';
