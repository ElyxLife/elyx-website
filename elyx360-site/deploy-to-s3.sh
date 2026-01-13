#!/bin/bash

# Elyx 360 - AWS S3 Deployment Script
# Similar to elyx-life / elyx-health deployment

set -e

echo "🚀 Deploying Elyx 360 to AWS S3..."
echo ""

# Configuration
S3_BUCKET="elyx-life"  # Main bucket (adjust if different)
S3_PATH="elyx360"      # Folder path in bucket (similar to elyx-life, elyx-health)
CLOUDFRONT_DIST_ID=""  # Add your CloudFront distribution ID here
AWS_PROFILE="default"  # Change if using a specific AWS profile

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Clean previous build
echo -e "${YELLOW}[1/5]${NC} Cleaning previous build..."
if [ -d "_site" ]; then
    rm -rf _site
fi

# Step 2: Build Jekyll site for production
echo -e "${YELLOW}[2/5]${NC} Building Jekyll site..."
JEKYLL_ENV=production bundle exec jekyll build

if [ ! -d "_site" ]; then
    echo "❌ Build failed - _site directory not found"
    exit 1
fi

echo -e "${GREEN}✓${NC} Site built successfully"

# Step 3: Sync to S3
echo -e "${YELLOW}[3/5]${NC} Syncing to S3: s3://${S3_BUCKET}/${S3_PATH}/"

aws s3 sync _site/ s3://${S3_BUCKET}/${S3_PATH}/ \
    --profile ${AWS_PROFILE} \
    --delete \
    --cache-control "public, max-age=3600" \
    --exclude ".git/*" \
    --exclude ".DS_Store"

echo -e "${GREEN}✓${NC} Files synced to S3"

# Step 4: Set specific cache headers for assets
echo -e "${YELLOW}[4/5]${NC} Setting cache headers for static assets..."

# Long cache for CSS/JS (1 year)
aws s3 cp s3://${S3_BUCKET}/${S3_PATH}/assets/ s3://${S3_BUCKET}/${S3_PATH}/assets/ \
    --recursive \
    --profile ${AWS_PROFILE} \
    --cache-control "public, max-age=31536000, immutable" \
    --metadata-directive REPLACE

# Short cache for HTML (1 hour)
aws s3 cp s3://${S3_BUCKET}/${S3_PATH}/ s3://${S3_BUCKET}/${S3_PATH}/ \
    --recursive \
    --profile ${AWS_PROFILE} \
    --exclude "*" \
    --include "*.html" \
    --cache-control "public, max-age=3600" \
    --metadata-directive REPLACE

echo -e "${GREEN}✓${NC} Cache headers updated"

# Step 5: Invalidate CloudFront cache (if configured)
if [ -n "$CLOUDFRONT_DIST_ID" ]; then
    echo -e "${YELLOW}[5/5]${NC} Invalidating CloudFront cache..."

    aws cloudfront create-invalidation \
        --profile ${AWS_PROFILE} \
        --distribution-id ${CLOUDFRONT_DIST_ID} \
        --paths "/${S3_PATH}/*"

    echo -e "${GREEN}✓${NC} CloudFront cache invalidated"
else
    echo -e "${YELLOW}[5/5]${NC} Skipping CloudFront invalidation (CLOUDFRONT_DIST_ID not set)"
fi

echo ""
echo -e "${GREEN}✅ Deployment complete!${NC}"
echo ""
echo "Site URL: https://careers.elyx.life"
echo "S3 Path: s3://${S3_BUCKET}/${S3_PATH}/"
echo ""
echo "Note: DNS must point careers.elyx.life to CloudFront/S3"
