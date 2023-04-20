# https://github.com/carvel-dev/secretgen-controller

kubectl apply -f https://github.com/carvel-dev/secretgen-controller/releases/latest/download/release.yml

apiVersion: v1
kind: Namespace
metadata:
  name: beenotice
---
apiVersion: v1
kind: Secret
metadata:
  name: registry-credential
  namespace: beenotice
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: <data>
---
apiVersion: secretgen.carvel.dev/v1alpha1
kind: SecretExport
metadata:
  name: registry-credential
  namespace: beenotice
spec:
  toNamespace: "*"

_________________________________________________

apiVersion: v1
kind: Secret
metadata:
  name: registry-credential
  namespace: demo
  annotations:
    secretgen.carvel.dev/image-pull-secret: ""
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: e30K
