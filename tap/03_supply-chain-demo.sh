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

# Deep dive only if requested (the intent is included in the config-template)
k get ClusterConfigTemplate convention-template -o yaml

___________________________________________
# Sonarqube
# https://bitnami.com/stack/sonarqube/helm
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install \
    -n sonarqube \
    --create-namespace \
    sonarqube \
    bitnami/sonarqube


export SERVICE_IP=$(kubectl get svc --namespace sonarqube sonarqube --template "{{ range (index .status.loadBalancer.ingress 0) }}{{ . }}{{ end }}")
echo "SonarQube URL: http://$SERVICE_IP/"

echo Username: user
echo Password: $(kubectl get secret --namespace sonarqube sonarqube -o jsonpath="{.data.sonarqube-password}" | base64 -d)


# Install tasks
# https://github.com/tektoncd/catalog/tree/main/task/sonarqube-scanner/0.2/

kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/git-clone/0.5/raw -n dev
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/sonarqube-scanner/0.2/raw -n dev

# Install Pipeline
# https://gitlab.eng.vmware.com/supply-chain-choreographer/catalog/-/blob/main/src/ootb-templates/bundle/config/testing-pipeline.yaml
kubectl apply -f $TAP_FILES_PATH/data/tekton-pipeline-sonar.yaml -n dev
k get pipeline,pipelinerun,pvc -n dev


https://github.com/x95castle1/custom-cartographer-supply-chain-examples
https://gitlab.com/drawsmcgraw/cartographer-sonar/-/blob/master/sonarqube-task.yml

https://hub.tekton.dev/tekton/task/sonarqube-scanner
https://github.com/tektoncd/catalog/tree/main/task/sonarqube-scanner/0.2


# Build
# https://gitlab.com/drawsmcgraw/cartographer-sonar/

# Export and update
kubectl get clustersupplychain source-to-url -o yaml
kubectl get clustersourcetemplate testing-pipeline -o yaml
kubectl get clusterruntemplate tekton-source-pipelinerun -o yaml

# Deploy
kubectl apply -f $TAP_FILES_PATH/supply-chain/
k get clustersupplychain

# Update workoad type to sonar and test