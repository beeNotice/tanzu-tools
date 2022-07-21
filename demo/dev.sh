#############################################
# Topics
#############################################
o Accelerate Cloud Native Java Application Development with Spring
o Innovate using trusted Open Source Software with VMware Application Catalog
o Build container images at scale using Cloud Native Buildpacks
o Keep an eye on your apps and your platforms with VMware Tanzu Observability

#############################################
# Prerequisites
#############################################
# Docker is Up and running
sudo sh tools/start-docker.sh
docker ps

# Namespace bnpp-demo-dev
k create ns bnpp-demo-dev

#############################################
# Code
#############################################
# Generate
# https://start.spring.io/

com.tanzu
bnpp-demo
bnpp-demo
com.tanzu.bnpp
    - Version 2.7.1
    - Spring Web
    - H2
    - Spring Data JPA
    - Rest Repositories
    - Actuator

# Eclipse
Generate > C:\Dev\workspaces
Import in Eclise > C:\Dev\workspaces\bnpp-demo\bnpp-demo

# Code
- Explore (pom.xml, HELP.md)
- Start App > http://localhost:8080/actuator/health
- Follow doc [Accessing JPA Data with REST](https://spring.io/guides/gs/accessing-data-rest/)
    - Entity
    - Repository

# Add OpenAPI
<springdoc.version>1.6.9</springdoc.version>

<!-- Open API -->
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-ui</artifactId>
    <version>${springdoc.version}</version>
</dependency>

<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-data-rest</artifactId>
    <version>${springdoc.version}</version>
</dependency>

# Explore HAL - Hypertext Application Language
    - http://localhost:8080/
    - Open Postman
        - Create two Persons
        - Show data
        - Search People http://localhost:8080/people/search/findByLastName?name=BNP

# Explore OpenAPI
    - http://localhost:8080/swagger-ui/index.html
    - http://localhost:8080/v3/api-docs

#############################################
# Deploy DB
#############################################
VAC Presentation

# Access KubeApps
export SERVICE_IP=$(kubectl get svc --namespace kubeapps kubeapps --template "{{ range (index .status.loadBalancer.ingress 0) }}{{ . }}{{ end }}")
echo "Kubeapps URL: http://$SERVICE_IP:80"
# Retrieve Token
kubectl get --namespace default secret kubeapps-operator-token -o jsonpath='{.data.token}' -o go-template='{{.data.token | base64decode}}' && echo

# Deploy
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install \
-n bnpp-demo-dev  \
--create-namespace \
--version 11.6.15 \
-f /mnt/c/Dev/workspaces/bnpp-k8s/helm/postgresql.yaml \
tanzu-app-postgresql \
bitnami/postgresql

# Check
kubectl get pods -n bnpp-demo-dev

# Start PostgreSQL locally
sh tools/start-postgresql.sh

# Prepare pom.xml
<dependency>
	<groupId>org.postgresql</groupId>
	<artifactId>postgresql</artifactId>
	<scope>runtime</scope>
</dependency>
		
# Prepare Configuration
spring:
  datasource:
    url: jdbc:postgresql://localhost/postgres-tanzu-app
    username: pgappuser
    password: pgappuser
  jpa:
    hibernate:
      ddl-auto: update

management:
  endpoint:
    health:
      show-details: always
		
# Launch App & Check
http://localhost:8080/

#############################################
# Build Container
#############################################
Présentation Cloud Native Buildpacks

# Push to repository bnpp-demo
https://github.com/beeNotice/bnpp-demo

cd /mnt/c/Dev/workspaces/bnpp-demo/bnpp-demo
git init
git add .
git commit -m "first commit"
git branch -M main
git remote add origin git@github.com:beeNotice/bnpp-demo.git
git push -u origin main

# Declare Image creation
cat /mnt/c/Dev/workspaces/bnpp-k8s/cnb/image.yaml
k apply -f /mnt/c/Dev/workspaces/bnpp-k8s/cnb/image.yaml

# Follow
kp build list -n dev
kp build logs bnpp-demo -n dev
kp build status bnpp-demo -n dev

# Go to Harbor
https://harbor.withtanzu.com/harbor/projects/9/repositories/bnpp-demo

#############################################
# Deploy App
#############################################
# Show files & explain principles
https://medium.com/google-cloud/kubernetes-nodeport-vs-loadbalancer-vs-ingress-when-should-i-use-what-922f010849e0

# https://carvel.dev/ytt/
# https://carvel.dev/kapp/
cd /mnt/c/Dev/workspaces/bnpp-k8s
ytt -f ./kapp -f values-dev.yaml

# Deploy
kapp deploy -a bnpp-demo-dev -c -f <(ytt -f ./kapp -f values-dev.yaml)

# Check
# kapp list
kapp inspect --app bnpp-demo-dev --tree
k get pods -n bnpp-demo-dev

# Access App
http://bnpp-demo-dev.tanzu.fmartin.tech
http://bnpp-demo-dev.tanzu.fmartin.tech/actuator/health

#############################################
# Patch
#############################################
# Constat
https://harbor.withtanzu.com/harbor/projects/9/repositories/bnpp-demo

kubectl get pods -n bnpp-demo-dev
kubectl exec -it POD -n bnpp-demo-dev -- bash -c "openssl version -a"

# Apply
kp clusterbuilder patch default --stack base
kp build list -n dev

#############################################
# TO
#############################################
Present TO
# https://spring.io/guides/gs/tanzu-observability/

https://start.spring.io/
    - wavefront
    - sleuth

# pom.xml
    - <xx.version>2.3.0</xx.version>
    - Dependency
    - dependencyManagement

# application.properties
wavefront:
  application:
    name: bnpp-demo
    service: dev

management:
  endpoints:
    web:
      exposure:
        include: '*'

# Start & Access application - Local
run-rest-simulation.cmd

# Pitch configuration upgrade

# Demo TO
Wavefront Demo
https://demo.wavefront.com/dashboards/Tanzu-Platform-Owner-Dashboard#_v01(g:(d:7200,ls:!t,s:1657542865))

#############################################
#  	 		 Clean
#############################################
helm delete tanzu-app-postgresql -n bnpp-demo-dev
kapp delete -a bnpp-demo-dev
k delete -f /mnt/c/Dev/workspaces/bnpp-k8s/cnb/image.yaml

docker ps --all
docker rm

Remove Harbor Applications > https://harbor.withtanzu.com/harbor/projects/9/repositories/bnpp-demo
Delete Git Repository > https://github.com/beeNotice/bnpp-demo
Delete workspace > C:\Dev\workspaces\bnpp-demo\bnpp-demo

kp clusterbuilder patch default --stack old

#############################################
# Annexes
#############################################
https://www.springcloud.io/post/2022-02/springframework-6/#gsc.tab=0


#############################################
# Troubleshooting
#############################################
kubectl patch pv pvc-6edc10be-5e77-4c6e-8fa1-477804e2237e -p '{"metadata":{"finalizers":null}}' --type=merge
k delete pvc data-tanzu-app-postgresql-0 -n bnpp-demo-dev