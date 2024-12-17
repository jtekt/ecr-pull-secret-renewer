# ECR pull secret renewer

A simple container to update an imagePullSecret in every namespace of a Kubernetes cluster in order to pull images from AWS ECR.

## Environment variables

- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- AWS_DEFAULT_REGION
- AWS_ECR_URL

## Development

### Loading environment variables from .env file for testing

```
[ -f .env ] && export $(grep -v '^#' .env | xargs)
```
