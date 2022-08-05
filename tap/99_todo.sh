# TODO
- Refactoring catalog-info
- Produce App documentation & links

- Blue / Green
- Existing/Legacy applications
- Deploy production on EKS

- Navigate APIs
- Offer API consummer

- Auto load APIs in the portal
Define the Cluster name in the Workload portal

Add Service Binding demo in the Actuator


Prerequisites
Lombok

https://vmware.slack.com/archives/C02D60T1ZDJ/p1656711397305319

sh $TAP_FILES_PATH/script/create-additional-dev-space.sh spring-petclinic

k apply -f /mnt/c/Dev/workspaces/spring-petclinic-tanzu/spring-petclinic-config-server/config/workload.yaml
k apply -f /mnt/c/Dev/workspaces/spring-petclinic-tanzu/spring-petclinic-discovery-server/config/workload.yaml


tanzu apps workload get spring-petclinic-discovery-server -n spring-petclinic
kp build logs spring-petclinic-discovery-server -n spring-petclinic

kubectl run busybox --image=busybox --rm -it --restart=Never -- wget -O- http://spring-petclinic-config-server.spring-petclinic.svc.cluster.local
