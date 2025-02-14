#!/bin/bash

# Exit on any error
set -e

# Set GCP project
PROJECT_ID="southern-zephyr-424910-j6"
echo "Setting GCP project to: ${PROJECT_ID}"
gcloud config set project ${PROJECT_ID}

echo "Starting deployment..."

# Deploy elyx.life
echo "Deploying to elyx.life..."
# First sync HTML files with no caching
gcloud storage rsync -r \
  --cache-control="no-cache, no-store, must-revalidate" \
  --include="*.html" \
  elyx-life gs://elyx.life

# Then sync all other files with long caching
gcloud storage rsync -r \
  --cache-control="public, max-age=31536000" \
  --exclude="*.html" \
  elyx-life gs://elyx.life

# Deploy elyx.health
echo "Deploying to elyx.health..."
# First sync HTML files with no caching
gcloud storage rsync -r \
  --cache-control="no-cache, no-store, must-revalidate" \
  --include="*.html" \
  elyx-health gs://elyx.health

# Then sync all other files with long caching
gcloud storage rsync -r \
  --cache-control="public, max-age=31536000" \
  --exclude="*.html" \
  elyx-health gs://elyx.health

echo "Deployment completed successfully!" 