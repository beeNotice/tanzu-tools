# App Live view
# Check running
kubectl get -n app-live-view service,deploy,pod
# In case of problem, try
kubectl -n app-live-view delete pods -l=name=application-live-view-connector