#!/bin/bash

# Delete objects
kubectl get svc,pvc --all-namespaces

# Delete workload cluster
tanzu cluster list
tanzu cluster delete tanzu-wkl

# Delete management cluster
tanzu management-cluster get
tanzu management-cluster delete tanzu-mgt

# Delete context
kubectl config get-contexts
kubectl config delete-context tanzu-mgt-admin@tanzu-mgt