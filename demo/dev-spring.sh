#######################
# Prerequisites
#######################

# Clean
Clean windows folder > tanzu-spring-demo
Clean K8s
Clean Eclipse

# Docker is Up and running
sudo sh tools/start-docker.sh
docker ps
K8s is running

#######################
# Intro
#######################
Intro Spring Boot

######################
# Starter
#######################

https://start.spring.io/
Maven
Java 19
com.tanzu
tanzu-spring-demo
tanzu-spring-demo
com.tanzu.spring.demo
Version 2.7.6
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
      - http://localhost:8080/greeting
      - http://localhost:8080/greeting?name=Fabien
    - Controller


# REST
- Follow doc [Accessing JPA Data with REST](https://spring.io/guides/gs/accessing-data-rest/)
    - Entity
    - Repository
      - Create two Persons
      - Show data
      - Search People http://localhost:8080/people/search/findByLastName?name=Baggins

#############################################
# Container
#############################################
- Follow doc [Create an OCI image](https://docs.spring.io/spring-boot/docs/2.7.5/maven-plugin/reference/html/#build-image)

cd /mnt/c/Dev/workspaces/tanzu-spring-demo
./mvnw spring-boot:build-image

docker image list | grep tanzu-spring-demo
docker run -p 8080:8080 tanzu-spring-demo:0.0.1-SNAPSHOT

# Push to remote
docker image tag tanzu-spring-demo:0.0.1-SNAPSHOT registry.cloud-garage.net/fmartin/tanzu-spring-demo:0.0.1-SNAPSHOT
docker image push registry.cloud-garage.net/fmartin/tanzu-spring-demo:0.0.1-SNAPSHOT

#############################################
# Deploy to K8s
#############################################
k apply -f /mnt/c/Dev/workspaces/tanzu-spring-demo-k8s
  - http://tanzu-spring-demo.tanzu.fmartin.tech/actuator/health

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

Remove C:\Users\fmartin\.wavefront_freemium
