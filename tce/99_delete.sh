tanzu unmanaged delete tce-local

# Uninstall CLI
https://tanzucommunityedition.io/docs/v0.11/cli-uninstall/
https://docs.vmware.com/en/Tanzu-Application-Platform/1.1/tap/GUID-uninstall.html#remove-tanzu-cli


# Remove kubectl
sudo rm $BIN_FOLDER/kubectl
sudo rm /etc/bash_completion.d/kubectl

# Remove Harbor Certs
sudo rm -Rf /etc/docker/certs.d/$HARBOR_URL
sudo rm -Rf ~/.docker/tls/$HARBOR_URL
