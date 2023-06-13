https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.5/tap/services-toolkit-tutorials-integrate-cloud-services.html
https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.5/tap/services-toolkit-about.html
https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.5/tap/getting-started-consume-services.html
https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.5/tap/services-toolkit-how-to-guides-dynamic-provisioning-rds.html


https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.5/tap/services-toolkit-tutorials-integrate-cloud-services.html

https://docs.vmware.com/en/Services-Toolkit-for-VMware-Tanzu-Application-Platform/0.9/svc-tlk/usecases-consuming_gcp_sql_with_crossplane.html#define-composite-resource-types-5
https://docs.vmware.com/en/Services-Toolkit-for-VMware-Tanzu-Application-Platform/0.9/svc-tlk/usecases-consuming_gcp_sql_with_config_connector.html

# Multi-Cloud
# https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.5/tap/services-toolkit-tutorials-abstracting-service-implementation.html

# GKE - Installation
# Activate the SQL APIs
# https://docs.vmware.com/en/Services-Toolkit-for-VMware-Tanzu-Application-Platform/0.9/svc-tlk/usecases-consuming_gcp_sql_with_crossplane.html

# Checks
k get Provider
kubectl get provider.pkg.crossplane.io crossplane-provider-gcp

PROJECT_ID=edf---ela
SA_NAME=crossplane-cloudsql

gcloud iam service-accounts create "${SA_NAME}" --project "${PROJECT_ID}"
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --role="roles/cloudsql.admin" \
  --member "serviceAccount:${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
gcloud iam service-accounts keys create creds.json --project "${PROJECT_ID}" --iam-account "${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

kubectl create secret generic gcp-creds -n crossplane-system --from-file=creds=./creds.json --dry-run=client -o yaml > gcp-creds.yaml
sops --encrypt gcp-creds.yaml > $TAP_GITOPS_FILES_PATH/clusters/$CLUSTER_NAME/cluster-config/config/custom/gcp-creds.sops.yaml

# Provision DB
# https://vmware.slack.com/archives/C02D60T1ZDJ/p1686317496677109
k apply -f $TAP_FILES_PATH/data/postgresql-gcp.yaml

# Check
k get CloudSQLInstance,XPostgreSQLInstance
k get PostgreSQLInstance -n dev

tanzu service classes list
tanzu services claimable list --class cloudsql-postgres -n dev


# EKS - Installation
# https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.5/tap/services-toolkit-how-to-guides-dynamic-provisioning-rds.html
# https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.5/tap/bitnami-services-tutorials-working-with-bitnami-services.html

kubectl get providers
tanzu service class list



