Vérifier la santé du cluster Tanzu Kubernetes
https://docs.vmware.com/fr/VMware-vSphere/7.0/vmware-vsphere-with-tanzu/GUID-AFAAD7D6-8EF9-41EC-A6FC-ACCD802E0787.html

Vérifier la santé de la machine Tanzu Kubernetes
https://docs.vmware.com/fr/VMware-vSphere/7.0/vmware-vsphere-with-tanzu/GUID-644993CC-1DAF-4CAF-99BF-964AF4661677.html

SSH connexion
https://docs.vmware.com/en/VMware-vSphere/7.0/vmware-vsphere-with-tanzu/GUID-37DC1DF2-119B-4E9E-8CA6-C194F39DDEDA.html

ssh jumpbox

# Retrieve IP
kctx shared
kubectl get virtualmachines -o wide

# Retrieve secret
kubectl get secrets tanzu-cluster-shared-ssh-password -o yaml | yq e '.data.ssh-passwordkey' - | base64 --decode
ssh vmware-system-user@TKGS-CLUSTER-NODE-IP-ADDRESS

# AVI
# SSH connection
ssh admin@172.17.6.4

# Access logs
# https://dev.to/ngschmidt/troubleshooting-with-vmware-nsx-alb-avi-vantage-23pc
ll /var/lib/avi/logs/ALL-EVENTS/
tail -1000 /opt/avi/log/vCenterMgr.log

# Connect to AVI Shell
shell
admin / pass
vinfra makehostaccessible <exihost>

== Proxy configuration

https://docs.docker.com/config/daemon/systemd/#httphttps-proxy
https://kind.sigs.k8s.io/docs/user/quick-start/#configure-kind-to-use-a-proxy

== Kind

docker network inspect kind

== TKG deployment error 

# Start Docker
sudo systemctl daemon-reload
sudo systemctl restart docker

# Point to the tmp created file to debug Kind 
kubectl get pods -A --kubeconfig=/home/fmartin/.kube-tkg/config -o wide
kubectl get pods -A --kubeconfig=/home/fmartin/.kube-tkg/tmp/config_XXXXX -o wide

kubectl describe pod cert-manager-webhook-fbfcb9d6c-mtl9k -n cert-manager --kubeconfig=/root/.kube-tkg/tmp/config_aW0iD526

# Debug
kubectl get po,deploy,cluster,kubeadmcontrolplane,machine,machinedeployment -A --kubeconfig /root/.kube-tkg/tmp/config_kdTfPqiu
kubectl logs deployment.apps/<deployment-name> -n <deployment-namespace> manager --kubeconfig /root/.kube-tkg/tmp/config_kdTfPqiu

# Clean jumpbox on a failed deployment
https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.1/vmware-tanzu-kubernetes-grid-11/GUID-troubleshooting-tkg-tips.html#clean-up-docker-after-unsuccessful-management-cluster-deployments-0

== Cluster API connectivity
# 10.173.91.3 is the AVI IP to access the management cluster
curl -s -k https://10.173.91.3:6443/version -vvv

== Overlays

tanzu cluster create CLUSTER_NAME --file CLUSTER_CONFIG --dry-run
génère la conf Cluster API mais ne crée pas le cluster, très utile pour debugger des overlays

ytt -f OVERLAY.yml -f K8S.yml -f VALUES.yml
pour utiliser ytt en direct et valider le comportement de l’overlay, plus rapide que faire un tanzu cluster create