# https://carvel.dev/

# Ytt demo
ytt -f $CARTOGRAPHER_FILES_PATH/ytt/config.yml -f $CARTOGRAPHER_FILES_PATH/ytt/values.yml
ytt -f $CARTOGRAPHER_FILES_PATH/ytt
ytt -f $CARTOGRAPHER_FILES_PATH/ytt | kubectl apply -f-
ytt -f $CARTOGRAPHER_FILES_PATH/ytt | kubectl delete -f-

# Kapp demo
kapp deploy -a sample-app -f $CARTOGRAPHER_FILES_PATH/kapp-sample
kapp inspect -a sample-app --tree

# Update deployment file
kapp deploy -a sample-app -f $CARTOGRAPHER_FILES_PATH/kapp-sample --diff-changes
kapp delete -a sample-app

# Kapp & ytt
kapp deploy -a sample-app -f <(ytt -f $CARTOGRAPHER_FILES_PATH/kapp-ytt)
kapp inspect -a sample-app --tree
k get pods -n test
kapp delete -a sample-app

# Kapp Controler
# https://github.com/vmware-tanzu/carvel-simple-app-on-kubernetes
# Create RBAC
kubectl apply -f $CARTOGRAPHER_FILES_PATH/kapp/00-init.yml
kubectl apply -f $CARTOGRAPHER_FILES_PATH/kapp/01-app.yml

k get Apps -n test

kubectl delete -f $CARTOGRAPHER_FILES_PATH/kapp

# https://github.com/vmware-tanzu/cartographer/blob/main/examples/basic-sc/README.md
# $CARTOGRAPHER_FILES_PATH/examples/basic-sc
