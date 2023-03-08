# Image signing
# https://goharbor.io/docs/1.10/working-with-projects/project-configuration/implementing-content-trust/
# https://www.youtube.com/watch?v=pPklSTJZY2E
# https://tanzu.vmware.com/developer/guides/harbor-gs/
# https://tanzu.vmware.com/content/blog/using-vmware-s-harbor-with-pks-and-why-kubernetes-needs-a-container-registry

# Enable Notary
export DOCKER_CONTENT_TRUST=1
export DOCKER_CONTENT_TRUST_SERVER=https://$NOTARY_URL

docker tag busybox:1.34.1 $HARBOR_URL/tanzu/busybox-signed:1.34.1
docker push $HARBOR_URL/tanzu/busybox-signed:1.34.1 # tanzu2021
unset DOCKER_CONTENT_TRUST

# Remove existing images (if image already exists, the check won't happen)
docker images --digests
docker rmi foo/bar@<digest>

# Enable content trust
docker pull harbor.haas-489.pez.vmware.com/tanzu/busybox@sha256:...
docker pull harbor.haas-489.pez.vmware.com/tanzu/busybox-signed@sha256:...

NOTE: Image with signature cannot be deleted

# Replication
# https://tanzu.vmware.com/developer/guides/harbor-as-docker-proxy/
# https://goharbor.io/docs/2.4.0/administration/configuring-replication/

NOTE: Do not use Dockerhub Proxy
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.5/rn/vmware-tanzu-kubernetes-grid-15-release-notes/index.html#known-issues-harbor

###########################################
# OVAs
###########################################
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/2.1/tkg-deploy-mc-21/mgmt-reqs-harbor.html
https://customerconnect.vmware.com/downloads/details?downloadGroup=TKG-210&productId=1400&rPId=100663#:~:text=Photon%20v4%20Harbor%20v2.6.3%20OVA
govc import.ova photon-4-harbor-v2.6.3+vmware.1-9c5c48c408fac6cef43c4752780c4b048e42d562.ova

HARBOR_OVA_NAME=photon-4-harbor-v2.6.3+vmware.1-9c5c48c408fac6cef43c4752780c4b048e42d562
HARBOR_OVA_PATH=${HARBOR_OVA_NAME}.ova

govc import.spec ${HARBOR_OVA_PATH} | jq '.Name="'${HARBOR_OVA_NAME}'"' | jq '.NetworkMapping [0].Network="'"${GOVC_NETWORK}"'"' > harbor-ova.json
govc import.ova -options=harbor-ova.json ${HARBOR_OVA_PATH}
govc vm.markastemplate ${HARBOR_OVA_NAME}
rm harbor-ova.json