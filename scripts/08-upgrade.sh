# Horizontal scale
tanzu cluster scale tanzu-wkl --worker-machine-count 3
tanzu cluster list --include-management-cluster
tanzu cluster get tanzu-wkl

# Upgrade version
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-upgrade-tkg-workload-clusters.html
# Import photon-3-kube-v1.20.8+vmware.1-tkg.2-9893064678268559535 OVA
tanzu cluster list --include-management-cluster
tanzu kubernetes-release get
tanzu cluster create --file tanzu-wkl.yaml --tkr v1.20.8---vmware.1-tkg.2

tanzu cluster list
tanzu cluster kubeconfig get tanzu-wkl-old --admin
kubectl config use-context tanzu-wkl-old-admin@tanzu-wkl-old

k apply -f $K8S_FILES_PATH/01-namespace.yaml
k apply -f $K8S_FILES_PATH/02-secret.yaml
k apply -f $K8S_FILES_PATH/03-deployment.yaml
k apply -f $K8S_FILES_PATH/04-service.yaml

# Continuous curl while upgrade
NGINX_IP=$(kubectl get services --namespace test nginx --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
while sleep 5
do 
    response=$(curl --write-out '%{http_code}' --silent --output /dev/null --connect-timeout 2 $NGINX_IP)
    if [ $response != "200" ]; then
        echo $response
    else
        echo "Ok"
    fi
done

# Perform upgrade
tanzu cluster available-upgrades get tanzu-wkl-old
tanzu cluster upgrade tanzu-wkl-old

