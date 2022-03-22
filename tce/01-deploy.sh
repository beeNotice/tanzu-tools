# Download
curl -H "Accept: application/vnd.github.v3.raw" \
    -L https://api.github.com/repos/vmware-tanzu/community-edition/contents/hack/get-tce-release.sh | \
    bash -s $TCE_RELEASE_VERSION $TCE_RELEASE_OS_DISTRIBUTION

# Unpack
tar xzvf ~/tce-linux-amd64-$TCE_RELEASE_VERSION.tar.gz

# Install
cd tce-linux-amd64-v0.10.0
./install.sh
cd -

# Check
tanzu unmanaged-cluster --help
tanzu unmanaged-cluster create tce-local -c calico -p 80:80 -p 443:443

# Navigate
k get nodes
kubectl get po -A