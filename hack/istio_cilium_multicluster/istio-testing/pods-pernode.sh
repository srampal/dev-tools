#!/bin/bash

# The purpose of this script is to deploy to each node in the cluster 2 pods. 
# Each pod will have an env var that shows it's zone.

function netpod () {
  kubectl run net${2}-${1} \
     --image overridden  --labels app=net,pod=net${2}-${1},node=${1}  --overrides \
    '{
      "spec":{
        "hostname": "net'${2}-${1}'",
	      "subdomain": "net",
        "nodeName": "'$1'",
        "containers":[{
          "name":"net",
          "image":"mauilion/debug"
        }]
      }
    }'
}

for worker in $(kubectl get nodes -o name | sed s/node.//)
  do
    for i in {1..2}
      do netpod $worker $i
    done
  done

kubectl create service clusterip net --tcp 8080 

