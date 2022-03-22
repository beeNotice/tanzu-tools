# Fix delete App
kubectl patch App simple-app -n test -p '{"metadata":{"finalizers":null}}' --type=merge