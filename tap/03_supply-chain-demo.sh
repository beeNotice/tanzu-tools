# Create secrets for app
# @ see 03-secret.yml

k apply -f $TANZU_APP_FILES_PATH/config/workload.yaml

# Workload logs
tanzu apps workload tail tanzu-app-deploy -n dev --since 1m

# Delete workload
tanzu apps workload delete tanzu-app-deploy -n dev

# Supply chain content
tanzu apps cluster-supply-chain list
k get ClusterSupplyChain source-test-scan-to-url -o yaml
kubectl tree workload tanzu-app

# Follow steps
tanzu apps workload get tanzu-app-deploy
kubectl get workload,gitrepository,sourcescan,pipelinerun,images.kpack,imagescan,podintent,app,services.serving -n dev
k get imagescan tanzu-app-deploy

k get ClusterImageTemplate ClusterTemplate ClusterDeploymentTemplate ClusterSupplyChain ClusterDelivery Deliverable Runnable Workload

# Scan result
kubectl get sourcescan -o yaml

# Promotion
# https://cartographer.sh/docs/v0.1.0/architecture/
# https://vmware.slack.com/archives/C0186SB6ATY/p1641500688016700

# Custom
# https://vmware.slack.com/archives/C02DQ1P7E2J/p1643301179060400

# Create ns prod + git-ssh (03_supply-chain-install.sh)


# Custom Delivery
k get ClusterDelivery delivery-basic -o yaml
k get ClusterDeploymentTemplate app-deploy -o yaml
k get ClusterSourceTemplate delivery-source-template -o yaml


k get Pipeline -o yaml
k get ScanPolicy -o yaml
kubectl get scantemplates


# https://github.com/vmware-tanzu/cartographer/tree/main/examples/basic-delivery/app-operator
# https://gitlab.eng.vmware.com/supply-chain-choreographer/catalog/-/blob/main/src/ootb-delivery-basic/bundle/config/delivery.yaml
# https://gitlab.eng.vmware.com/supply-chain-choreographer/catalog/-/tree/main/src/ootb-templates/bundle/config

k apply -f $TAP_FILES_PATH/data/Deliverable.yaml
k get Deliverable -A

kubectl get gitrepository,app,services.serving -n prod
