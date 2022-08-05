# Configure env
# https://docs.vmware.com/en/Tanzu-Application-Platform/1.2/tap/GUID-vscode-extension-install.html

# Launch VS Code
cd $TANZU_PETCLINIC_FILES_PATH
code .
cd -

# Start Live coding
Ctrl + Shift + P => Tanzu: Live Update Start

# Configure context
kubectl config set-context --current --namespace=fmartin

# Follow
kp build logs spring-petclinic-tanzu -n fmartin
tanzu apps workload get spring-petclinic-tanzu -n fmartin




## Notes
* Do not use parent pom and subpath, the parent won t be resolvable
