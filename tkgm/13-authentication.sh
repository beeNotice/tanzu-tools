###########################################
# Deploy Keycloack
###########################################
# Create a VM from the Ubuntu template - The one used for the Jumpbox
# Specify ssh key : cat .ssh/id_rsa.pub
KEYCLOAK_IP=10.220.43.80
ssh ubuntu@$KEYCLOAK_IP

# Java
sudo apt-get update
sudo apt install openjdk-17-jdk-headless unzip

# Keycloak 
# https://www.keycloak.org/getting-started/getting-started-zip
wget https://github.com/keycloak/keycloak/releases/download/18.0.0/keycloak-18.0.0.zip
unzip keycloak-18.0.0.zip

export KEYCLOAK_ADMIN=admin
export KEYCLOAK_ADMIN_PASSWORD=admin

# Copy SSL certificates
# Doesn't work OOTB with Self Signed Certificate
scp "/mnt/c/Users/fmartin/OneDrive - VMware, Inc/ssh/ssl/secured.beenotice.com.crt" ubuntu@$KEYCLOAK_IP:/home/ubuntu/cert.crt
scp "/mnt/c/Users/fmartin/OneDrive - VMware, Inc/ssh/ssl/beenotice.key" ubuntu@$KEYCLOAK_IP:/home/ubuntu/cert.key
scp "/mnt/c/Users/fmartin/OneDrive - VMware, Inc/ssh/ssl/GandiStandardSSLCA2.pem" ubuntu@$KEYCLOAK_IP:/home/ubuntu/GandiStandardSSLCA.pem

# WARNING : Append the Gandi CA to your domain certificate otherwise the curl and piniped won't work !
cat GandiStandardSSLCA.pem >> cert.crt

# https://www.keycloak.org/server/enabletls
keycloak-18.0.0/bin/kc.sh start-dev \
  --https-certificate-file=/home/ubuntu/cert.crt \
  --https-certificate-key-file=/home/ubuntu/cert.key \
  --https-port=8443

# Domaine, Add DNS A
https://admin.microsoft.com/AdminPortal/Home?#/Domains/Details/beenotice.com
A > secured.beenotice.com > $KEYCLOAK_IP
https://secured.beenotice.com:8443/


Add Realm > Tanzu
Add User & Set credentials
Add Group devops & add user to Group
Check login : https://secured.beenotice.com:8443/realms/tanzu/account/
Add Client : tanzu | openid-connect | https://www.keycloak.org/app/
    Acces Type : Confidential
    Retrieve Credentials
    Mappers > Create > groups > Group Membership > groups

# Well Know endpoints
# Retriev Issuer URL from here
https://secured.beenotice.com:8443/realms/tanzu/.well-known/openid-configuration

# Check
With Keycloack 18 :
curl --location --request POST 'https://secured.beenotice.com:8443/realms/tanzu/protocol/openid-connect/token' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'client_id=tanzu' \
--data-urlencode 'grant_type=password' \
--data-urlencode 'client_secret=0aOcYewOon02gAp4kmEFRppwFzRgzkGl' \
--data-urlencode 'scope=openid' \
--data-urlencode 'username=fmartin' \
--data-urlencode 'password=fmartin'

Check the JWT content to fill data bellow

###########################################
# Deploy TKG Cluster
###########################################
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-mgmt-clusters-enabling-id-mgmt.html
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-mgmt-clusters-configure-id-mgmt.html

# Prepare configuration
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-mgmt-clusters-config-vsphere.html
#! Settings for IDENTITY_MANAGEMENT_TYPE: "oidc"
IDENTITY_MANAGEMENT_TYPE: "oidc"
OIDC_IDENTITY_PROVIDER_CLIENT_ID: tanzu
OIDC_IDENTITY_PROVIDER_CLIENT_SECRET: 0aOcYewOon02gAp4kmEFRppwFzRgzkGl
OIDC_IDENTITY_PROVIDER_GROUPS_CLAIM: groups
OIDC_IDENTITY_PROVIDER_ISSUER_URL: https://secured.beenotice.com:8443/realms/tanzu
OIDC_IDENTITY_PROVIDER_SCOPES: email
OIDC_IDENTITY_PROVIDER_USERNAME_CLAIM: preferred_username

# Create Cluster
tanzu management-cluster create --file $HOME/.config/tanzu/tkg/clusterconfigs/mgmt-cluster-config.yaml

# Login as admin without Keycloak from the Jumbpbox
tanzu management-cluster kubeconfig get --admin
kubectl config use-context mgmt-admin@mgmt

# Check the configuration
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-mgmt-clusters-configure-id-mgmt.html#oidc
kubectl get oidcidentityprovider upstream-oidc-identity-provider -n pinniped-supervisor -o yaml

# Configure Keycloack with the callback url
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-mgmt-clusters-configure-id-mgmt.html#provide-the-callback-uri-to-the-oidc-provider-4
# WARNING - See the doc it depends of the presence of AVI or not
kubectl get all -n pinniped-supervisor
Or control_plane_endpoint

###########################################
# Login / Roles
###########################################

# Export connexion file
tanzu management-cluster kubeconfig get --export-file mgmt_kubeconfig
exit
scp ubuntu@10.220.43.89:/home/ubuntu/mgmt_kubeconfig .
kubectl get pods -A --kubeconfig mgmt_kubeconfig

# Create role
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-mgmt-clusters-configure-id-mgmt.html#create-a-role-binding-on-the-management-cluster-5
kubectl create clusterrolebinding id-mgmt-test-rb --clusterrole cluster-admin --user fmartin
k delete clusterrolebinding id-mgmt-test-rb
kubectl create clusterrolebinding id-mgmt-test-rb --clusterrole cluster-admin --group /devops

###########################################
# Troubleshooting
###########################################
# Check pinniped reconciliation
pinniped -n tkg-system

# On the Login page you have : Unprocessable Entity: No upstream providers are configured
# It means that the provider is not well configured
kubectl get oidcidentityprovider upstream-oidc-identity-provider -n pinniped-supervisor -o yaml

# Logout
rm .config/tanzu/pinniped/sessions.yaml

# You can try to fix the deploy with, and wait for the job to be completed
k delete oidcidentityprovider upstream-oidc-identity-provider -n pinniped-supervisor
kubectl delete jobs pinniped-post-deploy-job -n pinniped-supervisor
kubectl get job pinniped-post-deploy-job -n pinniped-supervisor

# Check connectivity
kubectl create job test-oidc-discovery \
  -n pinniped-supervisor \
  --image curlimages/curl \
  -- curl https://secured.beenotice.com:8443/realms/tanzu

kubectl logs job/test-oidc-discovery -n pinniped-supervisor
k delete job/test-oidc-discovery -n pinniped-supervisor

# Logs
k logs pinniped-concierge-647c6bdf8-grczr -n pinniped-concierge
k logs pinniped-supervisor-84b586c8df-nmb8k -n pinniped-supervisor

###########################################
# Appendix - Keycloak - Nginx
###########################################

# Start Keycloak
keycloak-18.0.0/bin/kc.sh start-dev --proxy edge
http://IP:8080/

# HTTPS
# https://www.digitalocean.com/community/tutorials/how-to-configure-nginx-with-ssl-as-a-reverse-proxy-for-jenkins
# https://nicolas.perriault.net/code/2012/gandi-standard-ssl-certificate-nginx/
sudo apt-get install nginx

sudo cp cert.crt /etc/nginx/cert.crt
sudo cp cert.key /etc/nginx/cert.key

sudo vi /etc/nginx/sites-enabled/default
=> copy data from data/nginx-default

sudo systemctl restart nginx
sudo systemctl status nginx