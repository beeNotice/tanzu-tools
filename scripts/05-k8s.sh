#!/bin/bash
# https://github.com/dgkanatsios/CKAD-exercises

# Create Docker secret to avoid rate limiting
kubectl create secret docker-registry docker-hub-creds \
--docker-server=$DOCKER_REGISTRY_SERVER \
--docker-username=$DOCKER_USER \
--docker-password=$DOCKER_PASSWORD \
--docker-email=$DOCKER_EMAIL \
-n test \
--dry-run=client \
-o yaml > $K8S_FILES_PATH/02-secret.yaml

# Update default SA to use this credential
kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "docker-hub-creds"}]}' --namespace=test

# Deploy k8s objects
k apply -f $K8S_FILES_PATH
k get svc -n test
kubectl exec -it nginx-f6ccb5668-22k9t -n test -- /bin/bash
kubectl exec nginx-f6ccb5668-22k9t -n test -- curl 100.69.237.145
kubectl run busybox --image=busybox --rm -it --restart=Never -n test -- /bin/sh

# Persistent Volumes
# Check Persistent Volumes ReadWriteOnce - 05-pvc.yaml
kubectl get storageclass
kubectl  get pvc -n test # Go find it in vCenter > Cluster, Monitor, Cloud Native Storage


# https://docs-staging.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-tanzu-k8s-clusters-storage.html
# https://www.tecmint.com/how-to-setup-nfs-server-in-linux/

# Deploy NFS Server
# https://github.com/vmware/photon/wiki/Downloading-Photon-OS
# Deploy OVF Template > https://packages.vmware.com/photon/4.0/GA/ova/photon-hw11-4.0-1526e30ba0.ova
# root / changeme
tdnf install -y nfs-utils
mkdir -p /mnt/nfs_share
chown -R nobody:nogroup /mnt/nfs_share/
chmod 777 /mnt/nfs_share/
vi /etc/exports
# /mnt/nfs_share  10.213.73.0/24(rw,sync,no_subtree_check)
# /mnt/nfs_share  10.213.72.0/24(rw,sync,no_subtree_check)
exportfs -ra
systemctl start nfs-server.service
showmount -e  10.213.73.203

# k8s NFS requires a provisionner : https://kubernetes.io/docs/concepts/storage/storage-classes/#nfs
# https://www.digitalocean.com/community/tutorials/how-to-set-up-readwritemany-rwx-persistent-volumes-with-nfs-on-digitalocean-kubernetes-fr
# https://artifacthub.io/packages/helm/kvaps/nfs-server-provisioner
# https://betterprogramming.pub/using-nfs-persistent-volumes-across-pods-in-readwritemany-mode-357a41eed6c9
# https://www.padok.fr/en/blog/readwritemany-nfs-kubernetes
# https://kubernetes.io/fr/docs/concepts/storage/persistent-volumes/

# Deploy NFS Server
helm repo add nfs-ganesha-server-and-external-provisioner https://kubernetes-sigs.github.io/nfs-ganesha-server-and-external-provisioner/
k create ns nfs-ganesha-server
helm install nfs-ganesha-server \
--namespace nfs-ganesha-server \
--version 1.4.0 \
nfs-ganesha-server-and-external-provisioner/nfs-server-provisioner

# Remove NFS Server
helm delete nfs-ganesha-server -n nfs-ganesha-server


# Add Datastore in VSphere
# https://docs.vmware.com/en/VMware-vSphere-Container-Storage-Plug-in/2.0/vmware-vsphere-csp-getting-started/GUID-606E179E-4856-484C-8619-773848175396.html
# Update datastoreurl with govc datastore.info Datastore
k apply -f $TANZU_TOOLS_FILES_PATH/k8s/pvc/01-nfs-storageclass.yaml
k apply -f $TANZU_TOOLS_FILES_PATH/k8s/pvc/02-pvc.yaml
k get pvc,pv -n test


# Check Envoy
ENVOY_IP=$(kubectl get services envoy -n tanzu-system-ingress --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl $ENVOY_IP # => Empty
curl -H "host: tanzu-tools.com" $ENVOY_IP # => Welcome

# Chaos testing
sh $TANZU_TOOLS_FILES_PATH/scripts/tools/curl-loop.sh

# Delete pod
k scale deployment nginx --replicas=3 -n test
k get pods -n test
k delete pod xx -n test

# Delete VM
# Shutdown and delete from Vcenter
k get nodes
tanzu cluster list
k get pods -n test -o wide

# Network policy
# https://kubernetes.io/docs/concepts/services-networking/network-policies/
# https://github.com/ahmetb/kubernetes-network-policy-recipes
k apply -f $K8S_FILES_PATH/07-network-policy.yaml
k get netpol -n test

# Check Ingress
kubectl run busybox --image=busybox --rm -it -n test --restart=Never -- wget -O- http://nginx.test.svc.cluster.local:80 --timeout 2
kubectl run busybox --image=busybox --rm -it -n test --restart=Never --labels=access=granted -- wget -O- http://nginx.test.svc.cluster.local:80 --timeout 2

# Check Egress
kubectl exec nginx-7f594698c6-d26ff -n test -- curl http://142.250.200.46 --connect-timeout 5
kubectl exec nginx-7f594698c6-d26ff -n test -- curl https://142.250.200.46  --connect-timeout 5 --insecure

k delete -f $K8S_FILES_PATH/07-network-policy.yaml