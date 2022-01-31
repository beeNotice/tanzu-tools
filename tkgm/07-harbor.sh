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

# Image with signature cannot be deleted
