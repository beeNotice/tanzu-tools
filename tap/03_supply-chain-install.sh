# Prepare Github
# https://docs.vmware.com/en/Tanzu-Application-Platform/1.0/tap/GUID-scc-ootb-supply-chain-basic.html#gitops
# https://github.com/pvdbleek/tanzu/blob/main/tap-minikube/gitops-workflow.md
# https://vmware.slack.com/archives/C02D60T1ZDJ/p1639034875225700
ssh-keygen -t ed25519
ssh-keyscan github.com > $HOME/known_hosts

# Create Dev Namespace for prod
# https://docs.vmware.com/en/Tanzu-Application-Platform/1.0/tap/GUID-install-components.html#setup
# @ see 02_deploy-aks.sh / 

# GitOps
# https://docs-staging.vmware.com/en/Tanzu-Application-Platform/1.1/tap/GUID-scc-ootb-supply-chain-basic.html#gitops
# Dry run to fill the file + Add the annotation -> tekton.dev/git-0: github.com
kubectl create secret generic git-ssh \
--from-file=ssh-privatekey=$HOME/.ssh/id_ed25519 \
--from-file=identity=$HOME/.ssh/id_ed25519 \
--from-file=identity.pub=$HOME/.ssh/id_ed25519.pub \
--from-file=known_hosts=$HOME/known_hosts \
--type=kubernetes.io/ssh-auth \
--dry-run=client \
-n $TAP_DEV_NAMESPACE \
-o yaml > $TAP_FILES_PATH/data/github-secret.yaml

kubectl apply -f $TAP_FILES_PATH/data/github-secret.yaml
kubectl annotate secret git-ssh tekton.dev/git-0='github.com' -n $TAP_DEV_NAMESPACE
kubectl patch serviceaccount default -p '{"secrets": [{"name": "git-ssh"}]}' -n $TAP_DEV_NAMESPACE
# Configuration pushed @ $(gitops.repository_prefix) + $(workload.name)

# Install
# https://docs.vmware.com/en/Tanzu-Application-Platform/1.0/tap/GUID-scc-install-ootb-sc-wtest-scan.html
tanzu package install ootb-supply-chain-testing-scanning \
  --package-name ootb-supply-chain-testing-scanning.tanzu.vmware.com \
  --version 0.6.1 \
  --namespace tap-install \
  --values-file $TAP_FILES_PATH/data/ootb-supply-chain-testing-scanning-values.yaml

# Check
# https://docs.vmware.com/en/Tanzu-Application-Platform/1.0/tap/GUID-scc-ootb-supply-chain-testing-scanning.html
tanzu apps cluster-supply-chain list
k get ClusterSupplyChain -A
k get ClusterSupplyChain source-test-scan-to-url -o yaml

# Create Tekton Pipeline
kubectl apply -f $TAP_FILES_PATH/data/tekton-pipeline.yaml
k get Pipeline -n dev

# Create scan policy
kubectl apply -f $TAP_FILES_PATH/data/scan-policy.yaml
k get ScanPolicy -n dev

# Create or check Templates
kubectl get scantemplates

# Deploy workload
tanzu apps workload create tanzu-java-web-app-deploy \
--git-repo https://github.com/sample-accelerators/tanzu-java-web-app \
--git-branch main \
--type web \
--label app.kubernetes.io/part-of=tanzu-java-web-app \
--label apps.tanzu.vmware.com/has-tests=true \
--namespace dev \
--yes

# Follow & check
k get Workload -A
tanzu apps workload get tanzu-java-web-app-deploy -n dev
k get pods -n dev
tanzu apps workload tail tanzu-java-web-app-deploy -n dev --since 1m

# GitOps will happen in https://github.com/beeNotice/tanzu-java-web-app-deploy

# Delete
tanzu apps workload delete tanzu-java-web-app-deploy -n dev

