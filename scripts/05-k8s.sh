#!/bin/bash

# Create Docker secret to avoid rate limiting
kubectl create secret docker-registry docker-hub-creds \
--docker-server=$DOCKER_REGISTRY_SERVER \
--docker-username=$DOCKER_USER \
--docker-password=$DOCKER_PASSWORD \
--docker-email=$DOCKER_EMAIL \
-n test \
--dry-run=client \
-o yaml > $K8S_FILES_PATH/02-secret.yaml

# kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "docker-hub-creds"}]}' --namespace=test

# Deploy k8s objects
k apply -f $K8S_FILES_PATH
k get svc -n test
kubectl exec -it nginx-f6ccb5668-22k9t -n test -- /bin/bash
kubectl exec nginx-f6ccb5668-22k9t -n test -- curl 100.69.237.145

# Check Persistent Volumes
kubectl get storageclass
kubectl  get pvc -n test # Go find it in vCenter > Cluster, Monitor, Cloud Native Storage

# Check Envoy
k get svc -A
curl 10.213.73.44 # => Empty
curl -H "host: tanzu-tools.com" 10.213.73.44 # => Welcome

