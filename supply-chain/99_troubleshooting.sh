# Fix delete App
kubectl patch App sample-app -n test -p '{"metadata":{"finalizers":null}}' --type=merge

