# Deploy Cluster
tanzu unmanaged-cluster create tce-local -c calico -p 80:80 -p 443:443

# Navigate
k get nodes
kubectl get po -A

# Extensions
# https://tanzucommunityedition.io/docs/v0.11/package-management/#adding-a-package-repository
# Check repository
tanzu package repository list --all-namespaces
tanzu package available list

# Intstall packages
tanzu package install cert-manager \
   --package-name cert-manager.community.tanzu.vmware.com \
   --version ${CERT_MANAGER_PACKAGE_VERSION}

tanzu package install contour \
   --package-name contour.community.tanzu.vmware.com \
   --version ${CONTOUR_PACKAGE_VERSION} \
--values-file $TANZU_TCE_FILES_PATH/data/contour-values.yaml

# Check
tanzu package installed list --all-namespaces

# Deploy App
# Note : Allow the access on port 80 if you are on a Cloud Provider
