#!/bin/bash

# Exit on any error
set -e

# Load environment variables
if [ ! -f .env ]; then
    echo "Error: .env file not found"
    exit 1
fi
source .env

if [ -z "$PROJECT_ID" ]; then
    echo "Error: PROJECT_ID not set in .env file"
    exit 1
fi

# Set GCP project
echo "Setting GCP project to: ${PROJECT_ID}"
gcloud config set project ${PROJECT_ID}

# Temporarily set quota project for this script
export GOOGLE_CLOUD_QUOTA_PROJECT=${PROJECT_ID}

echo "Starting deployment..."

# Deploy elyx.life
echo "Deploying to elyx.life..."
gcloud storage rsync -r \
  --cache-control="public, max-age=31536000" \
  --exclude=".*" \
  --exclude="*.DS_Store" \
  --exclude="__MACOSX" \
  --exclude="Thumbs.db" \
  --exclude="desktop.ini" \
  elyx-life gs://elyx.life

# Deploy elyx.health
echo "Deploying to elyx.health..."
gcloud storage rsync -r \
  --cache-control="public, max-age=31536000" \
  --exclude=".*" \
  --exclude="*.DS_Store" \
  --exclude="__MACOSX" \
  --exclude="Thumbs.db" \
  --exclude="desktop.ini" \
  elyx-health gs://elyx.health

echo "Deployment completed successfully!" 