#!/bin/bash

NGINX_IP=$(kubectl get services --namespace test nginx --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
while sleep 1
do 
    response=$(curl --write-out '%{http_code}' --silent --output /dev/null --connect-timeout 2 $NGINX_IP)
    if [ $response != "200" ]; then
        echo $response
    else
        echo "Ok"
    fi
done