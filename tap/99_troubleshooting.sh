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
k delete pods --all -n app-live-view

# Check applied convention
# https://docs.vmware.com/en/Application-Live-View-for-VMware-Tanzu/1.0/docs/GUID-troubleshooting.html
kubectl get podintents.conventions.apps.tanzu.vmware.com tanzu-app-deploy -o yaml

# Operation could not be completed as it results in exceeding approved Total Regional Cores quota
# https://docs.microsoft.com/en-us/azure/azure-portal/supportability/regional-quota-requests

# tap-values configuration
# If password has special characters, use single quotes around the pass


kubectl get workload,gitrepository,sourcescan,pipelinerun,images.kpack,imagescan,podintent,app,services.serving -n dev