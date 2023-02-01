# https://docs.microsoft.com/fr-fr/cli/azure/install-azure-cli-linux?pivots=apt
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Terraform
# https://learn.hashicorp.com/tutorials/terraform/install-cli
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform

# Krew
# https://krew.sigs.k8s.io/docs/user-guide/setup/install/
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)
echo 'PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> ~/.profile

# kubectl tree
# https://github.com/ahmetb/kubectl-tree
kubectl krew install tree

# Knative
# https://github.com/knative/client
sudo cp $TANZU_TOOLS_FILES_PATH/binaries/kn-linux-amd64 $BIN_FOLDER/kn
sudo chmod +x $BIN_FOLDER/kn

# Insight
# https://network.tanzu.vmware.com/products/supply-chain-security-tools
# https://docs.vmware.com/en/Tanzu-Application-Platform/1.0/tap/GUID-scst-store-cli_installation.html
chmod +x $TANZU_TOOLS_FILES_PATH/binaries/insight-1.0.1_linux_amd64
sudo cp $TANZU_TOOLS_FILES_PATH/binaries/insight-1.0.1_linux_amd64 $BIN_FOLDER/insight

# Brew - Facultatif
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/fmartin/.profile
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Tilt
# https://github.com/tilt-dev/ctlptl
curl -fsSL https://github.com/tilt-dev/ctlptl/releases/download/v$CTLPTL_VERSION/ctlptl.$CTLPTL_VERSION.linux.x86_64.tar.gz | sudo tar -xzv -C /usr/local/bin ctlptl

# https://docs.tilt.dev/install.html#linux
curl -fsSL https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.sh | bash

# Java
sudo apt install openjdk-17-jdk-headless

# Install kp
# https://network.pivotal.io/products/build-service/
# wget -O kp "$KP_URL"
sudo cp $TANZU_TOOLS_FILES_PATH/binaries/kp-linux-0.4.2 $BIN_FOLDER/kp
sudo chmod +x $BIN_FOLDER/kp

