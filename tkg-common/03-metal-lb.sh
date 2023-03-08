kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.9/config/manifests/metallb-native.yaml
kubectl apply -f $TANZU_TOOLS_FILES_PATH/tkg-common/data/metallb-config.yaml

k get all --namespace metallb-system