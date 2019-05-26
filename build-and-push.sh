#!/bin/bash
# In real world this should be rather handled via CLI but for this guide we'll be pushing the image manually...

set -e 
cd server

if ! [ -x "$(command -v jq)" ]; then
  echo 'Error: jq is not installed. Please install it first: https://stedolan.github.io/jq/' >&2
  exit 1
fi

if ! [ -x "$(command -v aws)" ]; then
  echo 'Error: AWS-CLI is not installed. Please install it first: https://aws.amazon.com/cli/' >&2
  exit 1
fi

if ! [ -x "$(command -v docker)" ]; then
  echo 'Error: Docker is not installed. Please install it first: https://www.docker.com/' >&2
  exit 1
fi

repositoryUri=$(aws ecr describe-repositories --region us-east-1 | jq -r '.repositories[] | select(.repositoryName=="terraform-vs-cdk") | .repositoryUri')
if [ -n "$repositoryUri" ]; then
  echo "Repository found, no need to create one."
else
  echo "Could not find terraform-vs-cdk ECR, creating..."
  repositoryUri=$(aws ecr create-repository --repository-name "terraform-vs-cdk" --region us-east-1 | jq -r .repository.repositoryUri)
fi

$(aws ecr get-login --no-include-email --region us-east-1)

docker build -t terraform-vs-cdk .
docker tag terraform-vs-cdk:latest "${repositoryUri}:latest"
docker push "${repositoryUri}:latest"

echo "Success!"
