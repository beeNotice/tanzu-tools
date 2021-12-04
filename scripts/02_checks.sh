#!/bin/bash
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-install-cli.html


###########################################
# Variables
###########################################
VCENTER="vcsa-01.haas-489.pez.vmware.com"


###########################################
# Script
###########################################

# Check NTP
date

# Check Cgroup 
docker info | grep -i cgroup

# Kind compatibility
sudo sysctl net/netfilter/nf_conntrack_max=131072

# Connectivity
curl https://$VCENTER --insecure

# Docker
docker login
docker run hello-world