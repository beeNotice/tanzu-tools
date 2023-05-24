# https://vmware.slack.com/archives/C02D60T1ZDJ/p1644235519946209
# Resource filter problem with Tekton test
       steps:
          - name: test
            image: maven:3-openjdk-11
            script: |-
              cd $(mktemp -d)
              wget -qO- $(params.source-url) | tar xvz --touch
              mvn test

# Delete Knative
k delete service.serving.knative.dev/tanzu-app-deploy -n dev

# Force delete
kubectl delete pod --grace-period=0 --force podName

# Live view
kubectl -n app-live-view-connector delete pods -l=name=application-live-view-connector

# Check applied convention
# https://docs.vmware.com/en/Application-Live-View-for-VMware-Tanzu/1.0/docs/GUID-troubleshooting.html
kubectl get podintents.conventions.apps.tanzu.vmware.com tanzu-app-deploy -o yaml

# Operation could not be completed as it results in exceeding approved Total Regional Cores quota
# https://docs.microsoft.com/en-us/azure/azure-portal/supportability/regional-quota-requests

# tap-values configuration
# If password has special characters, use single quotes around the pass
kubectl get workload,gitrepository,sourcescan,pipelinerun,images.kpack,imagescan,podintent,app,services.serving -n dev

# Image is not building
k describe image.kpack.io -n dev tanzu-java-web-app
=> Builder default is not ready

kubectl get clusterbuilder.kpack.io default
=> Ready False


# Delivery not working
You re using an RSA key with SHA-1, which is no longer allowed. Please use a newer client or a different key type.
=> ssh-keygen -t ed25519 -N "" -C ""

# Imgpkg
Error uploading images: Put "https://fmartin.azurecr.io/v2/fmartin/tap-packages/manifests/sha256-34c099ded5683dc08063ca1f61edfaab71fcb2f1a8253fae3e91a237b8134f47.imgpkg": http: ContentLength=1371 with Body length 0
=> Delete the image in the repository, and replay the imgpck

# Debug TAP installation
k get App -A
k describe App tap -n tap-install

###########################################
# Backstage Catalog
###########################################
# Logs are in the pod in the tap-gui
k logs server-5b4b49c5c6-fp7sv -n tap-gui

# Update Catalog after a Git Push
k delete pod server-5b4b49c5c6-fp7sv -n tap-gui

###########################################
# Special for TAP 1.2
###########################################
# Fix for deployment
kubectl create secret generic k8s-reader-overlay --from-file=$TAP_FILES_PATH/data/rbac_overlay.yaml -n tap-install

###########################################
# Metadata store fails
###########################################
# https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.4/tap/scst-store-troubleshooting.html#certificate-expiries-13
k logs metadata-store-app-f85cfcc49-xxgns -n metadata-store metadata-store-app
possibly because of \"x509: invalid signature: parent certificate cannot sign this kind of certificate

=> Exclude and reinstall pacakages
  - metadata-store.apps.tanzu.vmware.com
  - grype.scanning.apps.tanzu.vmware.com
  - scanning.apps.tanzu.vmware.com

# Reinstall from - Enable CVE scan results
03_supply-chain-install.sh


(
NAMESPACE=<rogue-namespace>
kubectl proxy &
kubectl get namespace $NAMESPACE -o json |jq '.spec = {"finalizers":[]}' >temp.json
curl -k -H "Content-Type: application/json" -X PUT --data-binary @temp.json 127.0.0.1:8001/api/v1/namespaces/$NAMESPACE/finalize
)

# 1 Insufficient cpu
k describe nodes
k top nodes
=> Chances are that the Pods are not well distributes
=> Delete pods on the overloaded Node