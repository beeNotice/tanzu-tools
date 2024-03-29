###########################################
# Resources
###########################################
* https://github.com/beeNotice/tanzu-app
* https://github.com/beeNotice/tanzu-app-deploy
* https://github.com/beeNotice/tap-gitops

###########################################
# Developer experience
###########################################
# Explore
http://tap-gui.tanzu.beenotice.eu/catalog?filters%5Bkind%5D=component&filters%5Buser%5D=owned

# Accelerators
http://tap-gui.tanzu.beenotice.eu/create?filters%5Bkind%5D=template&filters%5Buser%5D=all

# App Deployment
tanzu apps workload create -f $TANZU_APP_FILES_PATH/config/workload.yaml -y

# Follow
tanzu apps workload tail tanzu-app-deploy -n dev --timestamp --since 1h
tanzu apps workload get tanzu-app-deploy -n dev

# Access App & Infos
http://tap-gui.tanzu.beenotice.eu/catalog?filters%5Bkind%5D=component&filters%5Buser%5D=owned
- Status
- Logs
- Live View

# Access APIs
http://tap-gui.tanzu.beenotice.eu/api-docs?filters%5Bkind%5D=api&filters%5Buser%5D=all

###########################################
# Supply Chain
###########################################
# Supply Chain
tanzu apps workload get tanzu-app-deploy -n dev

http://tap-gui.tanzu.beenotice.eu/supply-chain
  - Follow
  - Security

# Supply chains
tanzu apps cluster-supply-chain list
tanzu apps cluster-supply-chain get source-test-scan-to-url

###########################################
# Cloud Native Buildpacks
###########################################
https://buildpacks.io/

# Current Status
kp build list -n dev
kp build status tanzu-app-deploy -n dev
kp build logs tanzu-app-deploy -n dev

# Patch
kp clusterstack list
kp clusterbuilder patch default --stack new

# Current Status
kp build list -n dev
tanzu apps workload get tanzu-app-deploy -n dev

###########################################
# Promotion
###########################################

# https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.5/tap/multicluster-getting-started.html
k apply -f $TANZU_APP_FILES_PATH/config/deliverable.yaml
k get pods -n dev
k logs

###########################################
# Service bindings
###########################################

k get ClassClaim -n dev
k get ClusterInstanceClass
k get xpostgresqlinstances.database.gcp.example.org -n dev
k get xpostgresqlinstances.bitnami.database.tanzu.vmware.com -n dev

k get pods --selector=app.kubernetes.io/component=run -n dev -o yaml | grep -i binding -C10
k get secret dd9a9a3e-6b83-4cae-9088-b7bbffb9c6b3 -n dev -o yaml
k exec -it tanzu-app-deploy-00004-deployment-96cf8db6-lgcrh -n dev -- /bin/sh
ls /bindings
ls /bindings/db
cat /bindings/db/host

http://tanzu-app-deploy.prod.tanzu.beenotice.eu/

###########################################
# Clean
###########################################
k delete -f $TANZU_APP_FILES_PATH/config/deliverable.yaml
k delete -f $TANZU_APP_FILES_PATH/config/workload.yaml

kp clusterbuilder patch default --stack base-jammy

