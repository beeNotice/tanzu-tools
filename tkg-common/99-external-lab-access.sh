# Setup
Deploy an OVA from https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.ova
Configure default pass and ssh key

# Configure
ssh ubuntu@IP

# Configure Keyboard
sudo vi /etc/default/keyboard
XKBLAYOUT="fr"

# Install VMware Tools - Required for Copy / Paste
# https://kb.vmware.com/s/article/1293
# https://docs.vmware.com/en/VMware-Tools/11.0.0/com.vmware.vsphere.vmwaretools.doc/GUID-C48E1F14-240D-4DD1-8D4C-25B6EBE4BB0F.html
sudo apt-get update
sudo apt-get install open-vm-tools-desktop
sudo apt-get install open-vm-tools


# Configure Copy Paste - vCenter
https://kb.vmware.com/s/article/57122
Ensure to log-in to the virtual machine using an account with Administrator or root privileges.
