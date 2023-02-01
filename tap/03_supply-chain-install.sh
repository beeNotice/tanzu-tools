# Install
# https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.3/tap/GUID-scc-install-ootb-sc-wtest-scan.html
tanzu package install ootb-supply-chain-testing-scanning \
  --package-name ootb-supply-chain-testing-scanning.tanzu.vmware.com \
  --version 0.10.5 \
  --namespace tap-install \
  --values-file $TAP_FILES_PATH/data/ootb-supply-chain-testing-scanning-values.yaml

# Check
# https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.3/tap/GUID-scc-ootb-supply-chain-testing-scanning.html
tanzu apps cluster-supply-chain list
k get ClusterSupplyChain -A
k get ClusterSupplyChain source-test-scan-to-url -o yaml

# Create scan policy
kubectl apply -f $TAP_FILES_PATH/data/scan-policy.yaml
k get ScanPolicy -n dev

# Create or check Templates
kubectl get scantemplates -n dev

# Create Tekton Pipeline
kubectl apply -f $TAP_FILES_PATH/data/tekton-pipeline.yaml
k get Pipeline -n dev

# Enable CVE scan results
# https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.3/tap/GUID-tap-gui-plugins-scc-tap-gui.html#scan
# Retrieve the token, and put it in tap-values-full.yml | tap_gui: app_config:  proxy: Authorization
# Be carrefull to keep the Bearer
kubectl get secrets metadata-store-read-write-client -n metadata-store -o jsonpath="{.data.token}" | base64 -d

# Update tap
tanzu package installed update tap \
     -p tap.tanzu.vmware.com \
     -v $TAP_VERSION \
     --values-file $TAP_FILES_PATH/data/tap-values-full.yml \
     -n tap-install

# Deploy workload (check that apps.tanzu.vmware.com/has-tests: "true")
tanzu apps workload create -f workload.yaml -y
