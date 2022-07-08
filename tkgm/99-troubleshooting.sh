###########################################
# Workload cluster creation
###########################################

worker nodes are still being created for MachineDeployment 'tkg-workload-md-0', DesiredReplicas=1 Replicas=1 ReadyReplicas=0 UpdatedReplicas=1, retrying

# Connect to the management-cluster
kubectl config use-context tanzu-mgt-admin@tanzu-mgt
kubectl get machinedeployments.cluster.x-k8s.io

###########################################
# SSH connect & debug
###########################################

ssh -i $PATH_TO_YOUR_PRIVATE_KEY capv@$NODE_IP
# Check services
systemctl --type service
systemctl status $SERVICE
sudo journalctl -fu $SERVICE -n300

systemctl status cloud-final.service

# Cloud init logs
sudo cat /var/log/cloud-init-output.log

# Check what's running
sudo crictl ps -a

== Workload Cluster scaling

k logs kapp-controller-6499b8866-nh2sw -n tkg-system

== Cluster upgrade

kubectl logs -n capv-system deploy/capv-controller-manager manager
k get delete node xx

###########################################
# Force Workload Cluster deletion
###########################################
# https://vmware.slack.com/archives/CSZCCLW0P/p1622659639142600
k get cluster -A
kubectl get machine -A
kubectl get vspheremachine -A

# Remove machines and finalizers
kubectl delete machine
kubectl patch machine <name> -p '{"metadata":{"finalizers":null}}' --type=merge
kubectl patch vspheremachine <name> -p '{"metadata":{"finalizers":null}}' --type=merge
kubectl patch cluster <name> -p '{"metadata":{"finalizers":null}}' --type=merge

== Volume is already exclusively attached to one node and can t be attached to another

* Detected on Grafana pod deployment
* https://kb.vmware.com/s/article/85213

###########################################
# Velero
###########################################
k logs velero-5f78f75d56-b7lfn -n velero

# Check Minio connectivity
mc alias set minio http://10.213.73.47:9000 admin T6PoL7CnyU1nBOZxG4a4c6Je4mOXY5PIeLREVmkJ
mc ls minio

# Velero uninstall doesn't remove backupstoragelocations.velero.io
k get crd | grep velero
k get backupstoragelocations.velero.io -n velero
k edit backupstoragelocations.velero.io default -n velero

###########################################
# Debug Management Cluster creation
###########################################
# If no VM are created in vSphere
Check that there are no overlap between Kind and the target netork
docker network inspect kind

# Point to the tmp created file to debug Kind 
kubectl get pods -A --kubeconfig=/home/ubuntu/.kube-tkg/config -o wide
kubectl get pods -A --kubeconfig=/home/ubuntu/.kube-tkg/tmp/config_uBHYW66M

# Debug
kubectl get po,deploy,cluster,kubeadmcontrolplane,machine,machinedeployment -A --kubeconfig /home/ubuntu/.kube-tkg/tmp/config_FiZmtXbJ
kubectl logs deployment.apps/<deployment-name> -n <deployment-namespace> manager --kubeconfig /home/ubuntu/.kube-tkg/tmp/config_FiZmtXbJ

# Good place to look
k logs deployment.apps/capi-kubeadm-control-plane-controller-manager -n capi-kubeadm-control-plane-system --kubeconfig=/home/ubuntu/.kube-tkg/tmp/config_FiZmtXbJ

###########################################
# Clean a failed deployment
###########################################
tanzu mc delete mgtmt

# Kind
kind get clusters
kind delete cluster --name tkg-kind-example1234567abcdef

# Docker
docker ps
docker kill container_ID

# vSphere
Shutdown and delete VM

# Cli
rm /home/ubuntu/.kube-tkg/tmp/*

# Clean Tanzu Context
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.5/vmware-tanzu-kubernetes-grid-15/GUID-cluster-lifecycle-multiple-management-clusters.html#delete-mc-config
rm ~/.config/tanzu/config.yaml
tanzu init

# Asaf clean stuff
rm -rf ~/.tkg
rm -rf ~/.kube-tkg
rm -rf ~/.tanzu
rm -rf ~/.kube
docker rm $(docker ps -a -q) --force
docker rmi $(docker images -a -q) --force
kind get clusters | xargs -n1 kind delete cluster --name

== Deployment

# Add -v 9 to add more details 
tanzu cluster create xxx -v 9

###########################################
# No Kube API
###########################################
ex : "https://10.220.31.108:6443/api?timeout=10s\": dial tcp 10.220.31.108:6443: connect: no route to host"

A connection refused suggests the VM itself doesn t have the APIServer running (or something in the middle is refusing the connection), so either
- IP conflicts
- APIserver failed to come up
- LoadBalancer isn t listening on that address/port.


###########################################
# Deleting a Cluster Stuck
###########################################

Remove the finalizers from kubectl edit cluster dev01

###########################################
# AVI
###########################################
kubectl get adc install-ako-for-management-cluster -o yaml
k logs ako-operator-controller-manager-6fdc98c4d8-vpmzj -n tkg-system-networking manager


