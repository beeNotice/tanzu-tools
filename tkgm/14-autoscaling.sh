# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.5/vmware-tanzu-kubernetes-grid-15/GUID-cluster-lifecycle-scale-cluster.html#scale-worker-nodes-with-cluster-autoscaler-0
# https://www.tacticalprogramming.com/cluster-node-autoscaling-in-tanzu-kubernetes-grid-tkg.html

# Prepare configuration
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-tanzu-config-reference.html#cluster-autoscaler-4
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-tanzu-k8s-clusters-vsphere.html

#! ---------------------------------------------------------------------
#! Autoscaler configuration
#! ---------------------------------------------------------------------
ENABLE_AUTOSCALER: true
AUTOSCALER_SCALE_DOWN_DELAY_AFTER_ADD: "2m"
AUTOSCALER_SCALE_DOWN_UNNEEDED_TIME: "2m"
AUTOSCALER_MIN_SIZE_0: 1
AUTOSCALER_MAX_SIZE_0: 5

# Create Cluster
tanzu cluster create --file $HOME/.config/tanzu/tkg/clusterconfigs/dev01-cluster-config.yaml

# Login
tanzu cluster kubeconfig get dev01 --admin
kubectl config use-context dev01-admin@dev01

# Check status
kubectl -n kube-system describe configmap cluster-autoscaler-status
kubectl get nodes

kubectl create deployment nginx --image=nginx --replicas=1
kubectl set resources deployment nginx -c=nginx --limits=cpu=500m,memory=512Mi
kubectl scale --replicas=10 deploy/nginx

k describe pod nginx-74bc69bcc4-jsm6g
=> 0/2 nodes are available: 1 Insufficient cpu
=> pod triggered scale-up

k delete deploy nginx
# Wait 2 minutes


# Edit configuration
kctx mgmt-admin@mgmt
kubectl get machinedeployments -o yaml
# cluster.k8s.io/cluster-api-autoscaler-node-group-max-size: "10"
# cluster.k8s.io/cluster-api-autoscaler-node-group-min-size: "3"