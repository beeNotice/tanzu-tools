CONTROL_PLANE_IP=10.220.47.162
KUBECTL_VSPHERE_USERNAME=administrator@vsphere.local
export KUBECTL_VSPHERE_PASSWORD=
kubectl vsphere login --server $CONTROL_PLANE_IP --vsphere-username $KUBECTL_VSPHERE_USERNAME --insecure-skip-tls-verify
