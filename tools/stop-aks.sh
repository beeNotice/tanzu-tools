#!/bin/bash

RG_NAME=rg-tanzu-demo-12
CLUSTER_NAME=tanzu-demo-fmartin
az aks stop --resource-group $RG_NAME --name $CLUSTER_NAME
