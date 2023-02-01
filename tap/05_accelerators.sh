###########################################
# Create your application accelerator
###########################################
# https://docs.vmware.com/en/Tanzu-Application-Platform/1.0/tap/GUID-getting-started.html#section-2-create-your-application-accelerator-10
# https://docs.vmware.com/en/Application-Accelerator-for-VMware-Tanzu/1.0/acc-docs/GUID-creating-accelerators-index.html
# http://tap-gui.fmartin.tech/create > New Accelerator > Follow README.yaml
# https://docs.vmware.com/en/Application-Accelerator-for-VMware-Tanzu/1.0/acc-docs/GUID-creating-accelerators-accelerator-yaml.html
kubectl apply -f $TAP_FILES_PATH/data/tanzu-app-accelerator/k8s-resource.yaml --namespace accelerator-system
k get Accelerator -n accelerator-system
tanzu accelerator list
# If you don't want to wait for 10 minutes after a Git update
tanzu accelerator update tanzu-app-demo -n accelerator-system --reconcile