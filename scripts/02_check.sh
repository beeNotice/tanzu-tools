#!/bin/bash
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-install-cli.html

# Check NTP
date

# Check Cgroup 
docker info | grep -i cgroup

# Kind compatibility
sudo sysctl net/netfilter/nf_conntrack_max=131072

# Connectivity
curl https://$GOVC_URL --insecure

# Docker
docker login
docker run hello-world
