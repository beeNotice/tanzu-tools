#!/bin/bash

# Delete objects
kubectl get svc,pvc --all-namespaces

# Delete workload cluster
tanzu cluster list
tanzu cluster delete tanzu-wkl

# Delete management cluster
tanzu management-cluster get
tanzu management-cluster delete tanzu-mgt

# Delete context
kubectl config get-contexts
kubectl config delete-context tanzu-mgt-admin@tanzu-mgt

# Delete CLI
# https://docs.vmware.com/en/Tanzu-Application-Platform/1.0/tap/GUID-uninstall.html#remove-tanzu-cli-plugins-and-associated-files-2
rm -rf $HOME/tanzu/cli        # Remove previously downloaded cli files
sudo rm /usr/local/bin/tanzu  # Remove CLI binary (executable)
rm -rf ~/.config/tanzu/       # current location # Remove config directory
rm -rf ~/.tanzu/              # old location # Remove config directory
rm -rf ~/.cache/tanzu         # remove cached catalog.yaml
rm -rf ~/Library/Application\ Support/tanzu-cli/* # Remove plug-ins
