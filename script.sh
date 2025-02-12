
#!/bin/bash

SECRET_NAME='ecr-credentials'
EXCEPTIONS=('kube-system' 'kube-node-lease' 'kube-public' 'ingress')

echo "Retrieving password from $AWS_ECR_URL"
PASSWORD=$(aws ecr get-login-password)

# Unsetting proxy so as to not interfere with kubectl
unset HTTP_PROXY
unset HTTPS_PROXY

NAMESPACES=$(kubectl get ns --no-headers |  awk '{print $1}')

for NAMESPACE in $NAMESPACES;
do
  # Check if namespace is an exception
  IS_EXCEPTION=false
  for EXCEPTION in "${EXCEPTIONS[@]}"; do
    if [[ "$EXCEPTION" == "$NAMESPACE" ]]; then
        IS_EXCEPTION=true
        break
    fi
  done

  if $IS_EXCEPTION;
  then
    echo "$NAMESPACE is an exception, skipping..."

  else 
    echo "Applying secret for namesapce $NAMESPACE"
    kubectl create secret docker-registry $SECRET_NAME \
      --docker-server=$AWS_ECR_URL \
      --docker-username=AWS \
      --docker-password $PASSWORD \
      --dry-run=client -o yaml \
      | kubectl apply -n $NAMESPACE -f - 
  fi
done

echo "Secret renewal complete"