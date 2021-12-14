#!/bin/bash

# Launch GUI
tanzu management-cluster create --ui --browser none
# Retrieve SSH Key
cat /home/tanzu/.ssh/id_rsa.pub

# Proxy configuration
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-tanzu-config-reference.html#proxy-configuration-5
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-mgmt-clusters-create-config-file.html#proxies

# Create management
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-mgmt-clusters-config-vsphere.html
tanzu management-cluster create --file /home/tanzu/tanzu-mgt.yaml

# Check management
tanzu management-cluster get
tanzu management-cluster kubeconfig get --admin
kubectl config use-context tanzu-mgt-admin@tanzu-mgt

kubectl get nodes -o wide
ssh capv@$node-ip
k get pods -A

# Create workload
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-tanzu-k8s-clusters-vsphere.html#tanzu-kubernetes-cluster-template-0
tanzu cluster create --file tanzu-wkl.yaml

# Check workload
tanzu cluster list
tanzu cluster kubeconfig get tanzu-wkl --admin
kubectl config use-context tanzu-wkl-admin@tanzu-wkl

kubectl get nodes -o wide
ssh capv@$node-ip
k get pods -A

# Cert Manager
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-packages-cert-manager.html
kubectl create ns $USER_PACKAGE_NAMESPACE
tanzu package available list cert-manager.tanzu.vmware.com -A

tanzu package install cert-manager \
--package-name cert-manager.tanzu.vmware.com \
--namespace $USER_PACKAGE_NAMESPACE \
--version $CERT_MANAGER_VERSION

kubectl get apps -A
kubectl get pods -n cert-manager

# Contour (requires Cert Manager)
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-packages-ingress-contour.html
tanzu package available list contour.tanzu.vmware.com -A
tanzu package install contour \
--package-name contour.tanzu.vmware.com \
--version $CONTOUR_VERSION \
--values-file contour-data-values.yaml \
--namespace $USER_PACKAGE_NAMESPACE

# Check k8s
tanzu package installed list -A
kubectl get apps -A
kubectl get pods -n tanzu-system-ingress

# Access Envoy
ENVOY_POD=$(kubectl -n tanzu-system-ingress get pod -l app=envoy -o name | head -1)
kubectl -n tanzu-system-ingress port-forward $ENVOY_POD 9001

# Prometheus
tanzu package available list prometheus.tanzu.vmware.com -A

tanzu package install prometheus \
--package-name prometheus.tanzu.vmware.com \
--namespace $USER_PACKAGE_NAMESPACE \
--version $PROMETHEUS_VERSION

tanzu package installed list -A

# Grafana
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-packages-grafana.html
tanzu package available list grafana.tanzu.vmware.com -A

image_url=$(kubectl -n tanzu-package-repo-global get packages grafana.tanzu.vmware.com.$GRAFANA_VERSION -o jsonpath='{.spec.template.spec.fetch[0].imgpkgBundle.image}')
imgpkg pull -b $image_url -o /tmp/grafana-package-$GRAFANA_VERSION
cp /tmp/grafana-package-$GRAFANA_VERSION/config/values.yaml grafana-data-values.yaml

sed -i "s/namespace: tanzu-system-monitoring/namespace: tanzu-system-dashboards/g" grafana-data-values.yaml
sed -i "s/admin_password: \"\"/admin_password: \"$(echo -ne "admin" | base64)\"/g" grafana-data-values.yaml
yq -i eval '... comments=""' grafana-data-values.yaml

tanzu package install grafana \
--package-name grafana.tanzu.vmware.com \
--version $GRAFANA_VERSION \
--values-file grafana-data-values.yaml \
--namespace $USER_PACKAGE_NAMESPACE

rm grafana-data-values.yaml

tanzu package installed list -A
k get svc -A
# tanzu-system-dashboards   grafana   LoadBalancer   100.64.72.226    10.213.73.46   80:31012/TCP
# https://grafana.com/grafana/dashboards/
# Metrics
topk(10, count by (__name__)({__name__=~".+"}))
count by (__name__)({__name__=~".+"})
# https://github.com/MichaelVL/kubernetes-grafana-dashboard/blob/master/dashboards/dashboard-kubernetes-health.py
sum(kube_node_info{node=~"$Node"})
sum(kube_pod_status_phase{phase="Running"})
sum(kube_persistentvolume_info)


# Fluent Bit
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-packages-logging-fluentbit.html

