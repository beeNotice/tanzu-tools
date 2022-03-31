# Install Supply Chain Security Tools - CLI
# https://network.tanzu.vmware.com/products/supply-chain-security-tools

# Retrieve IP
kubectl get service/metadata-store-app --namespace metadata-store

# Retrieve cert
mkdir $HOME/conf
kubectl get secret app-tls-cert -n metadata-store -o json | jq -r '.data."ca.crt"' | base64 -d > $HOME/conf/ca.crt

sudo vi /etc/hosts
51.11.233.193 metadata-store-app.metadata-store.svc.cluster.local

# Configure client
insight config set-target https://metadata-store-app.metadata-store.svc.cluster.local:8443 --ca-cert $HOME/conf/ca.crt
insight health

# Retirieve token
export METADATA_STORE_ACCESS_TOKEN=$(kubectl get secrets -n metadata-store -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='metadata-store-read-write-client')].data.token}" | base64 -d)

# Get image details
k get image
kp image list
insight image vulnerabilities --digest sha256:89a8ad65def38fce32125003bf2cca242e393c2a14a51b4d5a549a362940b870

# Image affected by a CVE
insight vulnerabilities get --cveid CVE-2022-0778


# Querying results
# https://docs-staging.vmware.com/en/VMware-Tanzu-Application-Platform/0.4/tap-0-4/GUID-scst-scan-viewing-reports.html
kubectl get sourcescans

insight source get \
  --repo  tanzu-app \
  --commit 9ca244c13367650ee01e6f0c76ae0ea213d58b93 \
  --org beeNotice

