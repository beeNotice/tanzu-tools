# https://docs.vmware.com/en/VMware-vSphere/7.0/vmware-vsphere-with-tanzu/GUID-1AEDB285-C965-473F-8C91-75724200D444.html
# https://github.com/vmware-tanzu/octant/releases
wget "https://github.com/vmware-tanzu/octant/releases/download/v0.25.0/octant_0.25.0_Linux-64bit.deb"
sudo dpkg -i octant_0.25.0_Linux-64bit.deb
rm octant_0.25.0_Linux-64bit.deb

# Run
octant 2> /dev/null &
http://127.0.0.1:7777/#/

# Stop via kill -9
