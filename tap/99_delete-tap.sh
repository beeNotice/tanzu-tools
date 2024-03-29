tanzu package installed delete tap -n tap-install

# Delete CLI
# https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.3/tap/GUID-uninstall.html#remove-tanzu-cli

rm -rf $HOME/tanzu/cli        # Remove previously downloaded cli files
sudo rm /usr/local/bin/tanzu  # Remove CLI binary (executable)
rm -rf ~/.config/tanzu/       # current location # Remove config directory
rm -rf ~/.tanzu/              # old location # Remove config directory
rm -rf ~/.cache/tanzu         # remove cached catalog.yaml
rm -rf ~/Library/Application\ Support/tanzu-cli/* # Remove plug-ins

# Delete Cluster essentials
# https://docs.vmware.com/en/Cluster-Essentials-for-VMware-Tanzu/1.3/cluster-essentials/GUID-deploy.html#uninstall-8

cd $HOME/tanzu-cluster-essentials
./uninstall.sh --yes