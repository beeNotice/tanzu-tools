# 2 installations strategy
  * Using operator, requires NSX-T : https://docs.vmware.com/en/VMware-vSphere/7.0/vmware-vsphere-with-tanzu/GUID-E7D7E987-2686-4458-BE9E-81A8D79D7859.html
  * Standalone : https://docs.vmware.com/en/VMware-vSphere/7.0/vmware-vsphere-with-tanzu/GUID-A24A6B91-0CDF-4D02-AD08-7BA5EAC25A42.html

# TMC

# Create SSH KeyPairs
https://aws.amazon.com/premiumsupport/knowledge-center/ec2-ssh-key-pair-regions/

# https://docs.vmware.com/en/VMware-Tanzu-Mission-Control/services/tanzumc-using/GUID-E728F568-5F1F-4963-A887-F09E2D19EA34.html
# https://docs.vmware.com/en/VMware-Tanzu-Mission-Control/services/tanzumc-using/GUID-750ADD13-F4CE-422A-BB08-F55304B4C355.html#GUID-750ADD13-F4CE-422A-BB08-F55304B4C355

# Trobleshoot | Clean
dataprotection.tmc.cloud.vmware.com already exists

https://console.aws.amazon.com/iam/home#/roles/VMwareTMCProviderCredentialMgr
S3 > Clean bucket
IAM > dataprotection.tmc.cloud.vmware.com


# Velero 
https://docs.vmware.com/en/VMware-Tanzu-Mission-Control/services/tanzumc-concepts/GUID-C16557BC-EB1B-4414-8E63-28AD92E0CAE5.html

# Velero config
kubectl get backupstoragelocations.velero.io -n velero