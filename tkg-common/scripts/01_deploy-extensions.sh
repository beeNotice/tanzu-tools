###########################################
# Cert Manager
###########################################
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-packages-cert-manager.html
kubectl create ns $USER_PACKAGE_NAMESPACE
tanzu package available list cert-manager.tanzu.vmware.com -A

# The namespace flag is used to determine where the app resource is created but not where cert-manager itself is deployed.
tanzu package install cert-manager \
--package-name cert-manager.tanzu.vmware.com \
--namespace $USER_PACKAGE_NAMESPACE \
--version $CERT_MANAGER_VERSION \
--values-file $TANZU_TOOLS_FILES_PATH/tkg-common/data/cert-manager-data-values.yaml

kubectl get apps -A
kubectl get pods -n cert-manager

###########################################
# Contour (requires Cert Manager)
###########################################
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-packages-ingress-contour.html
tanzu package available list contour.tanzu.vmware.com -A

tanzu package install contour \
--package-name contour.tanzu.vmware.com \
--version $CONTOUR_VERSION \
--values-file $TANZU_TOOLS_FILES_PATH/tkg-common/data/contour-data-values.yaml \
--namespace $USER_PACKAGE_NAMESPACE

# Check k8s
tanzu package installed list -A
kubectl get apps -A
kubectl get pods -n tanzu-system-ingress

# Access Envoy
ENVOY_POD=$(kubectl -n tanzu-system-ingress get pod -l app=envoy -o name | head -1)
kubectl -n tanzu-system-ingress port-forward $ENVOY_POD 9001


###########################################
# Prometheus
###########################################
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-packages-prometheus.html
tanzu package available list prometheus.tanzu.vmware.com -A

tanzu package install prometheus \
--package-name prometheus.tanzu.vmware.com \
--namespace $USER_PACKAGE_NAMESPACE \
--version $PROMETHEUS_VERSION \
--values-file $TANZU_TOOLS_FILES_PATH/tkg-common/data/prometheus-data-values.yaml

# Check
k get pods -n tanzu-system-monitoring
tanzu package installed list -A

###########################################
# Grafana
###########################################
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-packages-grafana.html
tanzu package available list grafana.tanzu.vmware.com -A

image_url=$(kubectl -n $USER_PACKAGE_NAMESPACE get packages grafana.tanzu.vmware.com.$GRAFANA_VERSION -o jsonpath='{.spec.template.spec.fetch[0].imgpkgBundle.image}')
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

GRAFANA_IP=$(kubectl get services grafana -n tanzu-system-dashboards --output jsonpath='{.status.loadBalancer.ingress[0].ip}')


# https://grafana.com/grafana/dashboards/
# Metrics
topk(10, count by (__name__)({__name__=~".+"}))
count by (__name__)({__name__=~".+"})
# https://github.com/MichaelVL/kubernetes-grafana-dashboard/blob/master/dashboards/dashboard-kubernetes-health.py
sum(kube_node_info{node=~"$Node"})
sum(kube_pod_status_phase{phase="Running"})
sum(kube_persistentvolume_info)


###########################################
# Fluent Bit
###########################################
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-packages-logging-fluentbit.html

# ELK (requires at least 3 nodes)
k create ns elasticsearch
helm repo add elastic https://helm.elastic.co
helm install elasticsearch --namespace elasticsearch --version 7.15.0 elastic/elasticsearch

# Check
kubectl run busybox --image=busybox --rm -it --restart=Never -n test -- wget -O- elasticsearch-master.elasticsearch.svc.cluster.local:9200

# Kibana
k create ns kibana
helm install kibana \
--set service.type=LoadBalancer \
--namespace kibana \
--set elasticsearchHosts=http://elasticsearch-master.elasticsearch.svc.cluster.local:9200 \
--version 7.15.0 \
elastic/kibana

# Fluent Bit
tanzu package install fluent-bit \
--package-name fluent-bit.tanzu.vmware.com \
--version $FLUENT_BIT_VERSION \
--values-file $TANZU_TOOLS_FILES_PATH/scripts/data/fluent-bit-data-values-es.yaml \
--namespace $USER_PACKAGE_NAMESPACE

tanzu package installed list -A

# Generate logs
kubectl run busybox-logs --image=busybox -n test --restart=Never -- /bin/sh -c 'i=0; while [ "$i" -lt 10 ]; do echo "$i: $(date)"; i=$((i+1)); sleep 1; done'
k logs busybox-logs -n test
k delete pod busybox-logs -n test

# Check logs
KIBANA_IP=$(kubectl get services kibana-kibana -n kibana --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
# KIBANA_IP:5601 > Management > Stack Management > Index Patterns > Create > logstash-*

GET /_cat/indices
GET /logstash-*/_search
{
  "query": {
    "match_phrase": {
      "kubernetes.container_name": "busybox-logs"
    }
  }
}

# Remove ELK
helm uninstall kibana -n kibana
helm uninstall elasticsearch -n elasticsearch
k get pvc -n elasticsearch
tanzu package installed delete fluent-bit --namespace $USER_PACKAGE_NAMESPACE

###########################################
# Harbor
###########################################
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-packages-harbor-registry.html
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-packages-external-dns.html

# Create cluster
tanzu cluster create --file $TANZU_TOOLS_FILES_PATH/tkgm-deploy-file/tanzu-shared-with-avi.yaml

# Declare as shared
kubectl config use-context tanzu-mgt-admin@tanzu-mgt
kubectl label cluster.cluster.x-k8s.io/tanzu-shared cluster-role.tkg.tanzu.vmware.com/tanzu-services="" --overwrite=true
tanzu cluster list --include-management-cluster

tanzu cluster kubeconfig get tanzu-shared --admin
kubectl config use-context tanzu-shared-admin@tanzu-shared
# Install Cert Manager & Contour

# Update hostname in harbor-data-values.yaml
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-packages-harbor-registry.html#deploy-harbor-into-the-shared-services-cluster-5
tanzu package install harbor \
--package-name harbor.tanzu.vmware.com \
--version $HARBOR_VERSION \
--values-file $TANZU_TOOLS_FILES_PATH/scripts/data/harbor-data-values.yaml \
--namespace $USER_PACKAGE_NAMESPACE

# Known issues
kubectl -n $USER_PACKAGE_NAMESPACE create secret generic harbor-notary-singer-image-overlay -o yaml --dry-run=client \
--from-file=$TANZU_TOOLS_FILES_PATH/scripts/data/overlay-notary-signer-image-fix.yaml \
| kubectl apply -f -
kubectl -n $USER_PACKAGE_NAMESPACE annotate packageinstalls harbor ext.packaging.carvel.dev/ytt-paths-from-secret-name.0=harbor-notary-singer-image-overlay

kubectl -n $USER_PACKAGE_NAMESPACE create secret generic harbor-database-redis-trivy-jobservice-registry-image-overlay -o yaml --dry-run=client \
--from-file=$TANZU_TOOLS_FILES_PATH/scripts/data/fix-fsgroup-overlay.yaml \
| kubectl apply -f -
kubectl -n $USER_PACKAGE_NAMESPACE annotate packageinstalls harbor ext.packaging.carvel.dev/ytt-paths-from-secret-name.1=harbor-database-redis-trivy-jobservice-registry-image-overlay

kubectl delete pods --all -n harbor

# Check
tanzu package installed list -A
# Routing is done through Contour/Envoy
kubectl get httpproxy -A

# Access
HARBOR_IP=$(kubectl get svc envoy -n tanzu-system-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
# Routing is done through Contour/Envoy
# kubectl get httpproxy -A
# Add DNS entry => harbor.haas-489.pez.vmware.com / notary.harbor.haas-489.pez.vmware.com

# Push & pull images
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-packages-harbor-registry.html#push-and-pull-images-to-and-from-the-harbor-package-7
# https://goharbor.io/docs/1.10/working-with-projects/project-configuration/implementing-content-trust/

# Register self signed certificates certificate
wget -O harbor.crt  https://$HARBOR_URL/api/v2.0/systeminfo/getcert --no-check-certificate

sudo mkdir -p /etc/docker/certs.d/$HARBOR_URL
sudo cp harbor.crt /etc/docker/certs.d/$HARBOR_URL/ca.crt
mkdir -p ~/.docker/tls/$HARBOR_URL
cp harbor.crt ~/.docker/tls/$HARBOR_URL/ca.crt
sudo mkdir -p /etc/docker/certs.d/$NOTARY_URL
sudo cp harbor.crt /etc/docker/certs.d/$NOTARY_URL/ca.crt
mkdir -p ~/.docker/tls/$NOTARY_URL
sudo cp harbor.crt ~/.docker/tls/$NOTARY_URL/ca.crt

# Deploy image
docker login $HARBOR_URL -u admin
docker pull busybox:1.34.1
docker tag busybox:1.34.1 $HARBOR_URL/tanzu/busybox:1.34.1
docker image list
docker push $HARBOR_URL/tanzu/busybox:1.34.1

# Add certificate to Worker nodes
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-cluster-lifecycle-secrets.html#trust-custom-ca-certificates-on-cluster-nodes-3
# https://vmware.slack.com/archives/CSZCCLW0P/p1625502325185600
cp $TANZU_TOOLS_FILES_PATH/scripts/data/custom-ca-overlay.yaml ~/.config/tanzu/tkg/providers/ytt/03_customizations/
cp harbor.crt ~/.config/tanzu/tkg/providers/ytt/03_customizations/tkg-custom-ca.pem
rm harbor.crt

# Apply to already deployed clusters
kctx tanzu-mgt-admin@tanzu-mgt
kubectl edit kubeadmconfigtemplate tanzu-wkl-md-0
# Update spec.files & preKubeadmCommands @see sample : 
kubectl patch machinedeployments.cluster.x-k8s.io tanzu-wkl-md-0 --type merge -p "{\"spec\":{\"template\":{\"metadata\":{\"annotations\":{\"date\":\"`date +'%s'`\"}}}}}"

# Check
kctx tanzu-wkl-admin@tanzu-wkl
kubectl run busybox --image=$HARBOR_URL/tanzu/busybox:1.34.1 --rm -it -n test --restart=Never -- /bin/sh
