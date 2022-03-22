# Prepare Github
# https://docs.vmware.com/en/Tanzu-Application-Platform/1.0/tap/GUID-scc-ootb-supply-chain-basic.html#gitops
# https://github.com/pvdbleek/tanzu/blob/main/tap-minikube/gitops-workflow.md
# https://vmware.slack.com/archives/C02D60T1ZDJ/p1639034875225700
ssh-keygen -t rsa
ssh-keyscan github.com > $HOME/known_hosts

# Create Dev Namespace for prod
# https://docs.vmware.com/en/Tanzu-Application-Platform/1.0/tap/GUID-install-components.html#setup
# @ see 02_deploy-aks.sh / 

# Dry run to fill the file + Add the annotation -> tekton.dev/git-0: github.com
kubectl create secret generic git-ssh \
--from-file=ssh-privatekey=$HOME/.ssh/id_rsa \
--from-file=identity=$HOME/.ssh/id_rsa \
--from-file=identity.pub=$HOME/.ssh/id_rsa.pub \
--from-file=known_hosts=$HOME/known_hosts \
--type=kubernetes.io/ssh-auth \
--dry-run=client \
-n dev \
-o yaml > $TAP_FILES_PATH/data/github-secret.yaml

kubectl apply -f $TAP_FILES_PATH/data/github-secret.yaml
kubectl annotate secret git-ssh tekton.dev/git-0='github.com' -n dev
kubectl patch serviceaccount default -p '{"secrets": [{"name": "git-ssh"}]}' -n dev
# Configuration pushed @ $(gitops.repository_prefix) + $(workload.name)

# Install
# https://docs.vmware.com/en/Tanzu-Application-Platform/1.0/tap/GUID-install-components.html#inst-ootb-sc-test-scan
tanzu package install ootb-supply-chain-testing-scanning \
  --package-name ootb-supply-chain-testing-scanning.tanzu.vmware.com \
  --version 0.5.1 \
  --namespace tap-install \
  --values-file $TAP_FILES_PATH/data/ootb-supply-chain-testing-scanning-values.yaml

# Check
# https://docs.vmware.com/en/Tanzu-Application-Platform/1.0/tap/GUID-scc-ootb-supply-chain-testing-scanning.html
tanzu apps cluster-supply-chain list

# Create Tekton Pipeline
kubectl apply -f $TAP_FILES_PATH/data/tekton-pipeline.yaml
k get Pipeline -n dev

# Create scan policy
kubectl apply -f $TAP_FILES_PATH/data/scan-policy.yaml
k get ScanPolicy -n dev

# Create or check Templates
kubectl get scantemplates

# Deploy workload
#tanzu apps workload create tanzu-app \
#  --git-branch main \
#  --git-repo https://github.com/beeNotice/tanzu-app \
#  --label apps.tanzu.vmware.com/has-tests=true \
#  --label app.kubernetes.io/part-of=tanzu-app \
#  --type web

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