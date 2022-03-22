# Problem downloding an image for pod
# failed size validation: 2097152 != 22246226: failed precondition
# Connect to the target Node through ssh, and download the image
sudo ctr image pull projects.registry.vmware.com/tkg/prometheus/prometheus_node_exporter@sha256:fb60a1618d016db12291197f6af703737ae793dbba6dc33a532afb1930007709


# Probleme installating Harbor, existing roles
k delete sa harbor-tanzu-package-repo-global-sa -n $USER_PACKAGE_NAMESPACE
k delete ClusterRole harbor-tanzu-package-repo-global-cluster-role -n $USER_PACKAGE_NAMESPACE
k delete ClusterRoleBinding harbor-tanzu-package-repo-global-cluster-rolebinding -n $USER_PACKAGE_NAMESPACE