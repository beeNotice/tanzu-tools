# https://cartographer.sh/docs/development/multi-cluster/
# https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.2/tap/GUID-multicluster-getting-started.html

# https://gitlab.eng.vmware.com/supply-chain-choreographer/catalog/-/tree/main/src/ootb-delivery-basic
# https://github.com/vmware-tanzu/cartographer/blob/main/examples/basic-delivery/README.md
# https://cartographer.sh/docs/development/reference/deliverable/
# https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.2/tap/GUID-scc-ootb-delivery-basic.html


kubectl apply -f $TAP_FILES_PATH/supply-chain/simple-delivery/deliverable.yaml -n prod
k get Deliverable -n prod
k describe ConfigMap scg-test -n prod

# Delete
kubectl delete -f $TAP_FILES_PATH/supply-chain/simple-delivery/deliverable.yaml -n prod

