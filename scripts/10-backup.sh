# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-cluster-lifecycle-backup-restore-mgmt-cluster.html
# https://blog.ippon.fr/2020/03/23/poc-1-velero-sauvegarder-des-applications-stateful-sur-kubernetes/

# Install Minio
# Apply Docker secret to minio namespace
k create ns minio
k apply -f $TANZU_TOOLS_FILES_PATH/k8s/02-secret.yaml

helm repo add bitnami https://charts.bitnami.com/bitnami
helm install minio bitnami/minio \
  --version 9.2.5 \
  --namespace minio \
  --set auth.rootUser=admin \
  --set auth.rootPassword=T6PoL7CnyU1nBOZxG4a4c6Je4mOXY5PIeLREVmkJ \
  --set service.type=LoadBalancer \
  --set global.imagePullSecrets[0]="docker-hub-creds"

# Create Bucket tkg-backup
MINIO_IP=$(kubectl get svc --namespace minio minio --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")
echo "MinIO&reg; web URL: http://$MINIO_IP:9001/minio"

# Install Velero
velero install \
--image=projects.registry.vmware.com/tkg/velero/velero:v1.6.2_vmware.1 \
--provider aws \
--plugins=projects.registry.vmware.com/tkg/velero/velero-plugin-for-aws:v1.2.1_vmware.1,projects.registry.vmware.com/tkg/velero/velero-plugin-for-vsphere:v1.1.1_vmware.1 \
--bucket tkg-backup \
--secret-file $TANZU_TOOLS_FILES_PATH/scripts/data/velero-credentials \
--backup-location-config "region=default,s3ForcePathStyle=true,s3Url=http://$MINIO_IP:9000" \
--snapshot-location-config region="default"

# Deploy things in test namespaces, for example pv, pods & co
velero backup create tanzu-backup --include-namespaces test
velero backup describe tanzu-backup
velero backup logs tanzu-backup

velero backup get

# Simulate disaster
k delete -f $K8S_FILES_PATH/04-service.yaml
k delete -f $K8S_FILES_PATH/03-deployment.yaml
k delete -f $K8S_FILES_PATH/pvc/02-pod-pvc.yaml
k delete -f $K8S_FILES_PATH/pvc/01-ReadWriteOnce-pvc.yaml

# Restore
velero restore create --from-backup tanzu-backup
velero restore describe tanzu-backup-20211217151244