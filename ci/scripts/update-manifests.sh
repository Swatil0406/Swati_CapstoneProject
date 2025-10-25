#!/bin/bash
set -e

FRONTEND_IMAGE=$1
BACKEND_IMAGE=$2
GIT_USER=$3
GIT_PASS=$4

# Update frontend deployment
sed -i "s|image: .*frontend.*|image: $FRONTEND_IMAGE|" ./k8s/apps/frontend/frontend-deployment.yaml

# Update backend deployment
sed -i "s|image: .*backend.*|image: $BACKEND_IMAGE|" ./k8s/apps/backend/backend-deployment.yaml

# Commit and push
git config user.email "jenkins@example.com"
git config user.name "Jenkins CI"

# Stage all YAMLs recursively
git add ./k8s/apps

# Commit only if there are changes
git diff --cached --quiet || git commit -m "Update frontend & backend images to latest"

# Push using credentials
git push https://$GIT_USER:$GIT_PASS@github.com/Swatil0406/Swati_CapstoneProject.git main
