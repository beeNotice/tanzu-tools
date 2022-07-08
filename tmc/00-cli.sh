# CLI commands
# https://developer.vmware.com/docs/11122/vmware-tanzu-mission-control-cli?h=VMware%20Tanzu%20Mission%20Control%20CLI
# https://brandon.azbill.dev/tmc-cli-guide/

# Access Cluster
# Install CLI
# https://docs.vmware.com/en/VMware-Tanzu-Mission-Control/services/tanzumc-using/GUID-7EEBDAEF-7868-49EC-8069-D278FD100FD9.html
# Just remove the .msi extension if downloading on windows
# TMC > Automation Center
curl -LO https://tmc-cli.s3-us-west-2.amazonaws.com/tmc/0.5.0-b1d98a1b/linux/x64/tmc
chmod +x tmc && sudo mv tmc /usr/local/bin/


# Common
tmc login # Use 'attached' if you want to go without a management cluster
tmc system context list
tmc cluster list --all

