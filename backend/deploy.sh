#!/bin/bash
set -e
export PATH=$PATH:/opt/homebrew/share/google-cloud-sdk/bin

PROJECT_ID="rd-antigravity-dev1"
REGION="us-central1"
ZONE="us-central1-a"
REPO_NAME="mobile-backend"
IMAGE_NAME="backend"
TAG="latest"

# Create Artifact Registry repository if it doesn't exist
if ! gcloud artifacts repositories describe $REPO_NAME --location=$REGION --project=$PROJECT_ID > /dev/null 2>&1; then
    echo "Creating Artifact Registry repository..."
    gcloud artifacts repositories create $REPO_NAME \
        --repository-format=docker \
        --location=$REGION \
        --description="Docker repository for mobile backend" \
        --project=$PROJECT_ID
fi

# Build and Push Docker image using Cloud Build
echo "Building and Pushing Docker image via Cloud Build..."
gcloud builds submit --tag $REGION-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/$IMAGE_NAME:$TAG .

# Apply Kubernetes manifests
echo "Deploying to GKE..."
# Ensure we are connected to the cluster
gcloud container clusters get-credentials gke-cluster --zone $ZONE --project $PROJECT_ID

kubectl apply -f k8s.yaml

echo "Deployment complete! Waiting for external IP..."
EXTERNAL_IP=""
while [ -z "$EXTERNAL_IP" ]; do
  echo "Waiting for LoadBalancer IP..."
  sleep 10
  EXTERNAL_IP=$(kubectl get svc backend-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)
done
echo "Backend available at: http://$EXTERNAL_IP"

