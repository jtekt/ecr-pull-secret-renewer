
#!/bin/bash

SECRET_NAME='ecr-credentials'
EXCEPTIONS=('kube-system' 'ingress' 'kube-public' 'kube-node-lease')

echo "Retrieving password from $AWS_ECR_URL"
PASSWORD=$(aws ecr get-login-password)

# Unsetting proxy so as to not interfere with kubectl
unset HTTP_PROXY
unset HTTPS_PROXY

NAMESPACES=$(kubectl get ns --no-headers |  awk '{print $1}')

for NAMESPACE in $NAMESPACES;
do
  if [[ ! $(echo ${EXCEPTIONS[@]} | fgrep -w $NAMESPACE ) ]]
  then
    echo "Applying secret for namesapce $NAMESPACE"
    kubectl create secret docker-registry $SECRET_NAME \
      --docker-server=$AWS_ECR_URL \
      --docker-username=AWS \
      --docker-password $PASSWORD \
      --dry-run=client -o yaml \
      | kubectl apply -n $NAMESPACE -f - 
  else 
    echo "$NAMESPACE is an exception, skipping..."
  fi
done

echo "Secret renewal complete"