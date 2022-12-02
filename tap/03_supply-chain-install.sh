# Prepare Github
# https://docs.vmware.com/en/Tanzu-Application-Platform/1.0/tap/GUID-scc-ootb-supply-chain-basic.html#gitops
# https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.2/tap/GUID-scc-gitops-vs-regops.html
# https://github.com/pvdbleek/tanzu/blob/main/tap-minikube/gitops-workflow.md
# https://vmware.slack.com/archives/C02D60T1ZDJ/p1639034875225700
ssh-keygen -t ed25519
ssh-keyscan github.com > $HOME/known_hosts

# Create Dev Namespace for prod
# https://docs.vmware.com/en/Tanzu-Application-Platform/1.0/tap/GUID-install-components.html#setup
# @ see 02_deploy-aks.sh / 

# Install
# https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.2/tap/GUID-scc-install-ootb-sc-wtest-scan.html
tanzu package install ootb-supply-chain-testing-scanning \
  --package-name ootb-supply-chain-testing-scanning.tanzu.vmware.com \
  --version 0.8.0-build.4 \
  --namespace tap-install \
  --values-file $TAP_FILES_PATH/data/ootb-supply-chain-testing-scanning-values.yaml

# Check
# https://docs.vmware.com/en/Tanzu-Application-Platform/1.0/tap/GUID-scc-ootb-supply-chain-testing-scanning.html
tanzu apps cluster-supply-chain list
k get ClusterSupplyChain -A
k get ClusterSupplyChain source-test-scan-to-url -o yaml

# Create Tekton Pipeline
kubectl apply -f $TAP_FILES_PATH/data/tekton-pipeline.yaml
# kubectl apply -f $TAP_FILES_PATH/data/tekton-pipeline-sonar.yaml
k get Pipeline -n dev


# Enable CVE scan results
# https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.2/tap/GUID-tap-gui-plugins-scc-tap-gui.html#scan
kubectl apply -f $TAP_FILES_PATH/data/metadata-store-ready-only.yaml
# Retrieve the token, and put it in tap-values-full.yml | tap_gui: app_config:  proxy: Authorization
kubectl get secret $(kubectl get sa -n metadata-store metadata-store-read-client -o json | jq -r '.secrets[0].name') -n metadata-store -o json | jq -r '.data.token' | base64 -d

# Update tap
tanzu package installed update tap \
     -p tap.tanzu.vmware.com \
     -v $TAP_VERSION \
     --values-file $TAP_FILES_PATH/data/tap-values-full.yml \
     -n tap-install

# Create scan policy
# https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.2/tap/GUID-scc-ootb-supply-chain-testing-scanning.html
kubectl apply -f $TAP_FILES_PATH/data/scan-policy.yaml
k get ScanPolicy -n dev

# Create or check Templates
kubectl get scantemplates -n dev

# Deploy workload (set apps.tanzu.vmware.com/has-tests: "true")
tanzu apps workload create -f $TANZU_APP_FILES_PATH/config/workload.yaml -y