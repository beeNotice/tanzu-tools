https://docs.vmware.com/en/VMware-Tanzu-Mission-Control/services/tanzumc-using/GUID-FADEC8C7-5DA0-4BEE-AE16-F4C7C7433123.html
https://console.cloudgate.vmware.com/ui


Provisionner : 
Administration > aws-hosted > Create Provisionner > fmartin-aws
Key pairs > Creat Key Pair > fmartin

# Access Cluster
# Install CLI
# Just remove the .msi extension if downloading on windows
kubectl --kubeconfig=conf/kubeconfig-fmartin-aws-demo.yml get namespaces

# Merge config
# https://medium.com/@jacobtomlinson/how-to-merge-kubernetes-kubectl-config-files-737b61bd517d

cp ~/.kube/config ~/.kube/config.bak # Merge the two config files together into a new config file 
KUBECONFIG=~/.kube/config:conf/kubeconfig-fmartin-aws-demo.yml kubectl config view --flatten > /tmp/config # Replace your old config with the new merged config 
mv /tmp/config ~/.kube/config # (optional) Delete the backup once you confirm everything worked ok 
rm ~/.kube/config.bak

# Delete entry
kubectl config unset users.fmartin-aws-demo
kubectl config unset contexts.fmartin-aws-demo
kubectl config unset clusters.fmartin-aws-demo