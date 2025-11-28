#!/usr/bin/env bash
set -euo pipefail

# Usage: ./build_and_push.sh <ECR_URI> <TAG>
ECR_URI=${1:-}
TAG=${2:-latest}

if [ -z "$ECR_URI" ]; then
  echo "Usage: $0 <ECR_URI> [TAG]"
  echo "Example: $0 123456789012.dkr.ecr.us-east-1.amazonaws.com/multi-env-devops-platform-dev latest"
  exit 1
fi

IMAGE="$ECR_URI/multi-env-app:$TAG"

echo "Building image $IMAGE"
docker build -t "$IMAGE" ./app

echo "Logging into ECR"
aws ecr get-login-password --region ${AWS_REGION:-us-east-1} | docker login --username AWS --password-stdin $(echo "$ECR_URI" | cut -d'/' -f1)

echo "Pushing image"
docker push "$IMAGE"

echo "Image pushed: $IMAGE"
