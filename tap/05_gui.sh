# Create your application accelerator
# https://docs.vmware.com/en/Tanzu-Application-Platform/1.0/tap/GUID-getting-started.html#section-2-create-your-application-accelerator-10
# https://docs.vmware.com/en/Application-Accelerator-for-VMware-Tanzu/1.0/acc-docs/GUID-creating-accelerators-index.html
# http://tap-gui.fmartin.tech/create > New Accelerator > Follow README.yaml
kubectl apply -f $TAP_FILES_PATH/data/tanzu-app-accelerator/k8s-resource.yaml --namespace accelerator-system
k get Accelerator -n accelerator-system

tanzu accelerator list

# Add application to the Application Platform GUI Software Catalog
# https://docs.vmware.com/en/Tanzu-Application-Platform/1.0/tap/GUID-getting-started.html#add-your-application-to-tanzu-application-platform-gui-software-catalog-5
http://tap-gui.fmartin.tech/catalog > Register Entity
https://github.com/beeNotice/tanzu-app/blob/main/catalog-info.yaml


# App Live view
# Check running
kubectl get -n app-live-view service,deploy,pod
# In case of problem, try
kubectl -n app-live-view delete pods -l=name=application-live-view-connector