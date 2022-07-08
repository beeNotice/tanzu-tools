###########################################
# Access management
###########################################
# https://docs.vmware.com/en/VMware-Tanzu-Mission-Control/services/tanzumc-concepts/GUID-EB9C6D83-1132-444F-8218-F264E43F25BD.html
# Note you have details of the role in the Administration page
Direct Access Policy > Create Role Binding > Admin | user | fmartin
Login and get nodes

Direct Access Policy > Create Role Binding > Admin | role | tanzu-devops

###########################################
# Custom Role - Manual
###########################################
# Cluster level
Administration > Roles > Create > tanzu-dev

Verbs : get, list, watch, create, update, delete
Type : resources
Values : pods

=> Assign role to user as before
k get pods -A  --kubeconfig=dev01_kubeconfig

# Namespace level
Administration > Roles > Create > tanzu-dev
Role visibility : Workspaces, Namespaces
Verbs : get, list, watch, create, update, delete
Type : resources
Values : pods

Create a Namespace fmartin
k get ns fmartin

Access > Workspaces > fmartin-app-workspace > fmartin

k get pods -n fmartin  --kubeconfig=dev01_kubeconfig

###########################################
# Custom Role - CLI
###########################################
# Create workspace
tmc workspace create --name $WORKSPACE_NAME

# Create namespace
tmc cluster namespace create -c <cluster name> -n <namespace name> -k <workspace name> -d "Insert description here"
tmc cluster namespace create -c $CLUSTER_NAME -n $NAMESPACE_NAME -k $WORKSPACE_NAME

=> NOTE:  You can use -p attached -m attached if you didn t specify it during the login phase

# Bind role
tmc cluster namespace iam add-binding $NAMESPACE_NAME --cluster-name $CLUSTER_NAME -g tanzu-devops -r tanzu-dev
tmc cluster namespace iam get-policy $NAMESPACE_NAME --cluster-name $CLUSTER_NAME

# Test
k run nginx --image=nginx -n fmartin
k get pods -n fmartin
k delete pod nginx -n fmartin

# Delete
tmc cluster namespace delete $NAMESPACE_NAME --cluster-name $CLUSTER_NAME
tmc workspace delete $WORKSPACE_NAME