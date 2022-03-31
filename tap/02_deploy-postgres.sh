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
