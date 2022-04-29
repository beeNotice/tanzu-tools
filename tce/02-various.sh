tanzu package install harbor \
   --package-name harbor.community.tanzu.vmware.com \
   --version $HARBOR_PACKAGE_VERSION \
   --values-file $TANZU_TCE_FILES_PATH/data/harbor-values.yaml

# Note the SSL part is not finished
wget -O harbor.crt  https://$HARBOR_URL/api/v2.0/systeminfo/getcert --no-check-certificate

# Local Docker
sudo mkdir -p /etc/docker/certs.d/$HARBOR_URL
sudo cp harbor.crt /etc/docker/certs.d/$HARBOR_URL/ca.crt
mkdir -p ~/.docker/tls/$HARBOR_URL
cp harbor.crt ~/.docker/tls/$HARBOR_URL/ca.crt

docker exec ${CLUSTER_NAME}-control-plane mkdir -p /etc/certs
docker cp harbor.crt ${CLUSTER_NAME}-control-plane:/etc/certs
docker exec ${CLUSTER_NAME}-control-plane cp /etc/certs/harbor.crt /usr/local/share/ca-certificates/$HARBOR_URL.crt
docker exec ${CLUSTER_NAME}-control-plane update-ca-certificates
sudo docker exec ${CLUSTER_NAME}-control-plane service containerd restart

# On a VM, configure dynamic proxy to Access Harbor
Putty > Connection > SSH > Tunnels > Source : 9090 | Destination Dynamic > Save
FoxyProxy > Add Regex .*(nip.io).*

# Access Habor (admin/admin)
https://harbor.127.0.0.1.nip.io


# Keel
# https://keel.sh/docs/#prerequisites
kubectl apply -f https://sunstone.dev/keel?namespace=keel&username=admin&password=admin&tag=latest
# Check
kubectl -n keel get pods