# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-build-images-index.html
# https://williamlam.com/2021/06/how-to-create-a-custom-tanzu-kubernetes-grid-tkg-node-ova-based-on-photon-os-real-time-kernel.html
# For example, in Tanzu Kubernetes Grid v1.4.2, the default Kubernetes version is v1.21.8.

BUILDER_NAME=TKG-Image-Builder-for-Kubernetes-v1.21.8-on-TKG-v1.4.2-master
BUILDER_ZIP_NAME=$BUILDER_NAME.zip
wget https://codeload.github.com/vmwarecode/TKG-Image-Builder-for-Kubernetes-v1.21.8-on-TKG-v1.4.2/zip/refs/heads/master -O $BUILDER_ZIP_NAME
unzip $BUILDER_ZIP_NAME
cd $BUILDER_NAME/TKG-Image-Builder-for-Kubernetes-v1.21.8+vmware.1-tkg-v1.4.2

# Create folder to put the generated OVA
mkdir /home/ubuntu/ova

# Add custom task
vi tkg/tasks/vsphere.yml
data/byoi/custom-task.yaml

# https://image-builder.sigs.k8s.io/capi/providers/vsphere.html#prerequisites-for-vsphere-builder
vi /home/ubuntu/vsphere.json
data/byoi/vsphere.json

vi /home/ubuntu/metadata.json
data/byoi/metadata.json

# Generate image - Takes about 20 minutes
docker run -it --rm \
    -v /home/ubuntu/vsphere.json:/home/imagebuilder/vsphere.json \
    -v $(pwd)/tkg.json:/home/imagebuilder/tkg.json \
    -v $(pwd)/tkg:/home/imagebuilder/tkg \
    -v $(pwd)/goss/vsphere-ubuntu-1.21.8+vmware.1-tkg-v1.4.2-goss-spec.yaml:/home/imagebuilder/goss/goss.yaml \
    -v /home/ubuntu/metadata.json:/home/imagebuilder/metadata.json \
    -v /home/ubuntu/ova:/home/imagebuilder/output \
    --env PACKER_VAR_FILES="tkg.json vsphere.json" \
    --env OVF_CUSTOM_PROPERTIES=/home/imagebuilder/metadata.json \
    projects.registry.vmware.com/tkg/image-builder:v0.1.9_vmware.1 \
    build-node-ova-vsphere-ubuntu-2004

=> Go to the vCenter and convert it to a Template 

# Run without tkr - This is the name of the VM
# Fill OS data to avoir default values
VSPHERE_TEMPLATE: ubuntu-2004-kube-v1.21.8
OS_NAME: "ubuntu"
OS_VERSION: "20.04"
OS_ARCH: "amd64"

# Create a TKr for the Linux Image
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-build-images-index.html#optional-create-a-tkr-for-the-linux-image-6

vi ~/.config/tanzu/tkg/bom/tkr-bom-v1.21.8+vmware.1-tkg.2.yaml
# Replace the version with the version specified in metadata.json eg: v1.21.8+vmware.1-fmartin.0
- name: ova-ubuntu-2004
  osinfo:
    name: ubuntu
    version: "20.04"
    arch: amd64
  version: v1.21.8+vmware.1-tkg.2-ed3c93616a02968be452fe1934a1d37c

# Copy file, replace + by ---
cp ~/.config/tanzu/tkg/bom/tkr-bom-v1.21.8+vmware.1-tkg.2.yaml tkr-bom-v1.21.8---vmware.1-tkg.2.yaml
cat tkr-bom-v1.21.8---vmware.1-tkg.2.yaml | base64 -w 0
# Fill binary content in the tkr.yaml
kctx mgmt-cluster-admin@mgmt-cluster
kubectl -n tkr-system apply -f tkr.yaml

# Apply changes
kubectl get pod -n tkr-system
kubectl delete pod -n tkr-system TKG-CONTROLLER

# Check
tanzu kubernetes-release get

# Try
# Be sure that OS_NAME, OS_VERSION and OS_ARCH match with tanzu kubernetes-release os get tkr-bom-v1.21.8---vmware.1-tkg.2 -o yaml
tanzu cluster create --file $HOME/.config/tanzu/tkg/clusterconfigs/dev01-cluster-config.yaml --tkr tkr-bom-v1.21.8---vmware.1-tkg.2
ssh capv@nodeIp
ls /tmp


# Troubleshooting

# Comptaibility file is here
cat /home/ubuntu/.config/tanzu/tkg/compatibility/tkg-compatibility.yaml


# OVA details
# https://developer.vmware.com/web/tool/4.4.0/ovf

. .govc.env
unzip VMware-ovftool-4.4.3-18663434-lin.x86_64.zip
ovftool/ovftool vi://$GOVC_USERNAME:$GOVC_PASSWORD@$GOVC_URL/vc01/vm/tkg/ubuntu-2004-kube-v1.21.8
ovftool/ovftool ova/ubuntu-2004-kube-v1.21.8/ubuntu-2004-kube-v1.21.8+vmware.1.ovf



https://docs.google.com/document/d/1tsyvGsWEbMxKFfx13FwQcTTcUFe345kiLXc6qS6ZJvg/edit