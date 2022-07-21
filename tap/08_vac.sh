# https://kubeapps.dev/

# Install
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install -n kubeapps  \
--create-namespace kubeapps \
--set frontend.service.type=LoadBalancer \
--set dashboard.resources.limits.memory=256Mi \
--set dashboard.resources.limits.cpu=500m \
bitnami/kubeapps

# Create Token
kubectl create --namespace default serviceaccount kubeapps-operator
kubectl create clusterrolebinding kubeapps-operator --clusterrole=cluster-admin --serviceaccount=default:kubeapps-operator
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: kubeapps-operator-token
  namespace: default
  annotations:
    kubernetes.io/service-account.name: kubeapps-operator
type: kubernetes.io/service-account-token
EOF

# Access
export SERVICE_IP=$(kubectl get svc --namespace kubeapps kubeapps --template "{{ range (index .status.loadBalancer.ingress 0) }}{{ . }}{{ end }}")
echo "Kubeapps URL: http://$SERVICE_IP:80"

# Retrieve Token
kubectl get --namespace default secret kubeapps-operator-token -o jsonpath='{.data.token}' -o go-template='{{.data.token | base64decode}}' && echo

# Delete
helm uninstall kubeapps -n kubeapps