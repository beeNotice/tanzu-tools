# https://github.com/Azure-Samples/acme-fitness-store
# https://learn.microsoft.com/en-us/azure/spring-apps/quickstart?tabs=Azure-CLI

WORKSPACE_PATH=/mnt/c/Dev/workspaces/tanzu-asa
cd $WORKSPACE_PATH

export RESOURCE_GROUP=rg-tanzu-asa
export SPRING_APPS_SERVICE=asa-tanzu-fmartin
export REGION=francecentral
export HELLO_SERVICE_APP="hello-service"
export LOG_ANALYTICS_WORKSPACE=lo-tanzu-asa

# Resource Group
az group create --name ${RESOURCE_GROUP} \
    --location ${REGION}

# Azure Spring Apps Enterprise
az spring create --name ${SPRING_APPS_SERVICE} \
    --resource-group ${RESOURCE_GROUP} \
    --location ${REGION} \
    --sku Enterprise \
    --enable-application-configuration-service \
    --enable-service-registry \
    --enable-gateway \
    --enable-api-portal \
    --build-pool-size S2

# Common configuration
az configure --defaults \
    group=${RESOURCE_GROUP} \
    location=${REGION} \
    spring=${SPRING_APPS_SERVICE}

# Logs configuration
az monitor log-analytics workspace create \
  --workspace-name ${LOG_ANALYTICS_WORKSPACE} \
  --location ${REGION} \
  --resource-group ${RESOURCE_GROUP}

export LOG_ANALYTICS_RESOURCE_ID=$(az monitor log-analytics workspace show \
    --resource-group ${RESOURCE_GROUP} \
    --workspace-name ${LOG_ANALYTICS_WORKSPACE} | jq -r '.id')

export SPRING_APPS_RESOURCE_ID=$(az spring show \
    --name ${SPRING_APPS_SERVICE} \
    --resource-group ${RESOURCE_GROUP} | jq -r '.id')

az monitor diagnostic-settings create --name "send-logs-and-metrics-to-log-analytics" \
    --resource ${SPRING_APPS_RESOURCE_ID} \
    --workspace ${LOG_ANALYTICS_RESOURCE_ID} \
    --logs '[
         {
           "category": "ApplicationConsole",
           "enabled": true,
           "retentionPolicy": {
             "enabled": false,
             "days": 0
           }
         },
         {
            "category": "SystemLogs",
            "enabled": true,
            "retentionPolicy": {
              "enabled": false,
              "days": 0
            }
          },
         {
            "category": "IngressLogs",
            "enabled": true,
            "retentionPolicy": {
              "enabled": false,
              "days": 0
             }
           }
       ]' \
       --metrics '[
         {
           "category": "AllMetrics",
           "enabled": true,
           "retentionPolicy": {
             "enabled": false,
             "days": 0
           }
         }
       ]'

# Create an App
az spring app create --name ${HELLO_SERVICE_APP} \
    --instance-count 1 \
    --memory 1Gi

# Déploiement d'une application
az spring app deploy --name hello-asae \
    --source-path hello-asae

# Configure Application Configuration Service
az spring application-configuration-service git repo add --name tanzu-asa-config \
    --label main \
    --patterns "hello/asa" \
    --uri "https://github.com/beeNotice/tanzu-asa" \
    --search-paths "config"

# Bind Application to Configuration
az spring application-configuration-service bind --app ${HELLO_SERVICE_APP}

# Bind Application to Service
az spring service-registry bind --app ${HELLO_SERVICE_APP}

# API Gateway
az spring gateway update --assign-endpoint true

export GATEWAY_URL=$(az spring gateway show | jq -r '.properties.url')
echo $GATEWAY_URL
   
az spring gateway update \
    --api-description "Tanzu Azure Spring Apps demo API" \
    --api-title "Tanzu Azure Spring Apps" \
    --api-version "v1.0" \
    --server-url "https://${GATEWAY_URL}" \
    --allowed-origins "*" \
    --no-wait

# https://learn.microsoft.com/fr-fr/azure/spring-apps/how-to-use-enterprise-spring-cloud-gateway
# Create route
az spring gateway route-config create \
    --name ${HELLO_SERVICE_APP} \
    --app-name ${HELLO_SERVICE_APP} \
    --routes-file routes/hello-service.json

# API Portal
az spring api-portal update --assign-endpoint true
export PORTAL_URL=$(az spring api-portal show | jq -r '.properties.url')
echo $PORTAL_URL

###########################################
# Demo
###########################################
# Refresh
# https://learn.microsoft.com/en-us/azure/spring-apps/how-to-enterprise-application-configuration-service#refresh-strategies
# The refresh frequency is managed by Azure Spring Apps and fixed to 60 seconds.
# Update value at https://github.com/beeNotice/tanzu-asa/blob/main/config/hello-asa.yaml
export SPRING_APPS_TEST_ENDPOINT=$(az spring test-endpoint list \
    --name ${SPRING_APPS_SERVICE} \
    --resource-group ${RESOURCE_GROUP} | jq -r '.primaryTestEndpoint')

curl ${SPRING_APPS_TEST_ENDPOINT}/${HELLO_SERVICE_APP}/default/actuator/refresh -d {} -H "Content-Type: application/json"

# Prepare Blue/Green deployments
az spring app deployment create --name blue --app ${HELLO_SERVICE_APP}

# Deploy Hello Service
az spring app deploy --name ${HELLO_SERVICE_APP} \
    --deployment blue \
    --config-file-pattern hello/asa \
    --source-path hello-service \
    --env 'SPRING_PROFILES_ACTIVE=asa'

# Promote
az spring app set-deployment -n ${HELLO_SERVICE_APP} --deployment blue
az spring app deployment delete --name default --app ${HELLO_SERVICE_APP}

###########################################
# Day 2
###########################################
az spring app restart -n ${HELLO_SERVICE_APP}

az spring app list --output table
az spring app show --name ${HELLO_SERVICE_APP} --query properties.activeDeployment.properties.instances --output table

az spring app logs --name ${HELLO_SERVICE_APP} --follow --deployment blue


###########################################
# Endpoints
###########################################
asa-tanzu-fmartin-gateway-70d55.svc.azuremicroservices.io
/
/service-instances/hello-service
/invoke-hello



# Demo
Slides
Support VMware Spring Runtime
Azure Spring Apps
  - App, Deploy, instance
  - Integration
  - Blue Green
Build
Config
Service
  - /invoke-hello
Cloud
  - https://asa-tanzu-fmartin-gateway-70d55.svc.azuremicroservices.io/
API
  - https://asa-tanzu-fmartin-apiportal-27833.svc.azuremicroservices.io/group/tanzu-azure-spring-apps
