###########################################
# Stop
###########################################
gcloud container clusters resize $CLUSTER_NAME --region $COMPUTE_REGION --num-nodes 0

gcloud container clusters delete \
    --zone $CLUSTER_ZONE \
    $CLUSTER_NAME



#!/bin/bash

# GKE
COMPUTE_REGION=europe-west9
COMPUTE_ZONE="$REGION-a"
CLUSTER_NAME=gke-tanzu-demo-fmartin

gcloud container clusters resize $CLUSTER_NAME --region $COMPUTE_REGION --num-nodes 3