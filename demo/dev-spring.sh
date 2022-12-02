#######################
# Prerequisites
#######################

# Clean
Clean windows folder
Clean images on the Registry
Clean K8s
Clean Eclipse

# Docker is Up and running
sudo sh tools/start-docker.sh
docker ps

K8s is running
k create ns tanzu-spring-demo
kubectl create secret docker-registry azure-reg-cred \
  --docker-server=$REGISTRY_HOSTNAME \
  --docker-username=$REGISTRY_USERNAME \
  --docker-password=$REGISTRY_PASSWORD \
  --docker-email=$REGISTRY_EMAIL \
  --namespace tanzu-spring-demo
kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "azure-reg-cred"}]}' --namespace=tanzu-spring-demo

#######################
# Intro
#######################
Intro Spring Boot

https://github.com/beeNotice/tanzu-spring-demo

#######################
# Starter
#######################

https://start.spring.io/
Maven
Java 11
com.tanzu
tanzu-spring-demo
tanzu-spring-demo
com.tanzu.spring.demo
    - Version 2.7.5
    - Spring Web
    - H2
    - Spring Data JPA
    - Rest Repositories
    - Actuator
Generate > C:\Dev\workspaces
Extract > Remove the project name
Import in Eclise > C:\Dev\workspaces\tanzu-spring-demo

#############################################
#					 Code
#############################################
# Application
- Explore (pom.xml, HELP.md)
- Start App > http://localhost:8080/actuator/health
- Follow doc [Building a RESTful Web Service](https://spring.io/guides/gs/rest-service/)
    - Greeting 
    - Controller
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

# Explore App
- http://localhost:8080/
- http://localhost:8080/v3/api-docs
- http://localhost:8080/swagger-ui/index.html
    - Create two Persons
    - Show data
    - Search People http://localhost:8080/people/search/findByLastName?name=Tanzu

#############################################
# Container
#############################################
- Follow doc [Create an OCI image](https://docs.spring.io/spring-boot/docs/2.7.5/maven-plugin/reference/html/#build-image)

cd /mnt/c/Dev/workspaces/tanzu-spring-demo
./mvnw spring-boot:build-image

docker image list
docker run -p 8080:8080 tanzu-spring-demo:0.0.1-SNAPSHOT

# Push to remote
docker image tag tanzu-spring-demo:0.0.1-SNAPSHOT fmartin.azurecr.io/fmartin/tanzu-spring-demo:0.0.1-SNAPSHOT
docker image push fmartin.azurecr.io/fmartin/tanzu-spring-demo:0.0.1-SNAPSHOT

#############################################
# Deploy to K8s
#############################################
k apply -f /mnt/c/Dev/workspaces/tanzu-spring-demo-k8s

#############################################
# TO
#############################################
Present TO
# https://spring.io/guides/gs/tanzu-observability/

https://start.spring.io/
    - wavefront

# pom.xml
    - <xx.version>2.3.0</xx.version>
    - Dependency
    - dependencyManagement

Show doc [Wavefront for Spring Boot documentation](https://docs.wavefront.com/wavefront_springboot.html)

#######################
# Clean
#######################
docker image rm 
