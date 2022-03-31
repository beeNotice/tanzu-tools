#!/bin/bash

if [ -z "$1" ]
  then
    echo "No argument for the developer namespace supplied"
    exit 1
fi

TAP_NAMESPACE=$1
echo "Creating the developer namespace to $TAP_NAMESPACE"

# Create ns
kubectl create ns $TAP_NAMESPACE

# Create registry secret
tanzu secret registry add registry-credentials \
--server $TAP_REGISTRY_HOSTNAME \
--username $TAP_REGISTRY_USERNAME \
--password $TAP_REGISTRY_PASSWORD \
--namespace $TAP_NAMESPACE

# Create git secret (Used by Gitops)
kubectl create secret generic git-ssh \
--from-file=ssh-privatekey=$HOME/.ssh/id_ed25519 \
--from-file=identity=$HOME/.ssh/id_ed25519 \
--from-file=identity.pub=$HOME/.ssh/id_ed25519.pub \
--from-file=known_hosts=$HOME/known_hosts \
--type=kubernetes.io/ssh-auth \
--dry-run=client \
-n $TAP_NAMESPACE
kubectl annotate secret git-ssh tekton.dev/git-0='github.com' -n $TAP_NAMESPACE
kubectl patch serviceaccount default -p '{"secrets": [{"name": "git-ssh"}]}' -n $TAP_NAMESPACE

# Create roles
cat <<EOF | kubectl -n $TAP_NAMESPACE apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: tap-registry
  annotations:
    secretgen.carvel.dev/image-pull-secret: ""
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: e30K
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: default
secrets:
  - name: registry-credentials
imagePullSecrets:
  - name: registry-credentials
  - name: tap-registry
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: default
rules:
- apiGroups: [source.toolkit.fluxcd.io]
  resources: [gitrepositories]
  verbs: ['*']
- apiGroups: [source.apps.tanzu.vmware.com]
  resources: [imagerepositories]
  verbs: ['*']
- apiGroups: [carto.run]
  resources: [deliverables, runnables]
  verbs: ['*']
- apiGroups: [kpack.io]
  resources: [images]
  verbs: ['*']
- apiGroups: [conventions.apps.tanzu.vmware.com]
  resources: [podintents]
  verbs: ['*']
- apiGroups: [""]
  resources: ['configmaps']
  verbs: ['*']
- apiGroups: [""]
  resources: ['pods']
  verbs: ['list']
- apiGroups: [tekton.dev]
  resources: [taskruns, pipelineruns]
  verbs: ['*']
- apiGroups: [tekton.dev]
  resources: [pipelines]
  verbs: ['list']
- apiGroups: [kappctrl.k14s.io]
  resources: [apps]
  verbs: ['*']
- apiGroups: [serving.knative.dev]
  resources: ['services']
  verbs: ['*']
- apiGroups: [servicebinding.io]
  resources: ['servicebindings']
  verbs: ['*']
- apiGroups: [services.apps.tanzu.vmware.com]
  resources: ['resourceclaims']
  verbs: ['*']
- apiGroups: [scanning.apps.tanzu.vmware.com]
  resources: ['imagescans', 'sourcescans']
  verbs: ['*']
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: default
subjects:
  - kind: ServiceAccount
    name: default
EOF

