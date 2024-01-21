#!/bin/bash

secretName='ecr-credentials'
namespaces=$(kubectl get ns --no-headers |  awk '{print $1}')
password=$(curl http://10.115.1.100:30990/password)

for namespace in $namespaces;
do

  isException=false

  # TODO: have this as env var
  for ex in 'kube-system' 'ingress' 'kube-public' 'kube-node-lease';
  do
    if [ "$ex" == "$namespace" ]; 
    then
      isException=true
    fi
  done

  if ! $isException ;
  then
    echo "Applying secret for namesapce $namespace"
    kubectl create secret docker-registry $secretName \
      --docker-server=732469118990.dkr.ecr.ap-northeast-1.amazonaws.com \
      --docker-username=AWS \
      --docker-password $password \
      --dry-run=client -o yaml \
      | kubectl apply -n $namespace -f - 
  fi
  
done

