#!/bin/bash

# Elyx 360 - AWS S3 Deploy Script
# Uploads _site/ to S3 and invalidates CloudFront cache.
# Run build.sh first to generate _site/.

set -e

# Configuration
S3_BUCKET="360-elyx-life-static"
S3_PATH=""             # Root of bucket (no subfolder)
CLOUDFRONT_DIST_ID="E3FDAE39VEYN3X"
AWS_PROFILE="default"  # Change if using a specific AWS profile

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Verify build exists
if [ ! -d "_site" ]; then
    echo "❌ _site/ not found. Run ./build.sh first."
    exit 1
fi

echo "🚀 Deploying Elyx 360 to AWS S3..."
echo ""

# Build S3 URI (handle empty S3_PATH for root-of-bucket deploys)
if [ -n "$S3_PATH" ]; then
    S3_URI="s3://${S3_BUCKET}/${S3_PATH}"
    CF_PATH="/${S3_PATH}/*"
else
    S3_URI="s3://${S3_BUCKET}"
    CF_PATH="/*"
fi

# Step 1: Sync to S3
echo -e "${YELLOW}[1/3]${NC} Syncing to S3: ${S3_URI}/"

aws s3 sync _site/ ${S3_URI}/ \
    --profile ${AWS_PROFILE} \
    --delete \
    --cache-control "public, max-age=3600" \
    --exclude ".git/*" \
    --exclude ".DS_Store"

echo -e "${GREEN}✓${NC} Files synced to S3"

# Step 2: Set specific cache headers for assets
echo -e "${YELLOW}[2/3]${NC} Setting cache headers for static assets..."

# Long cache for CSS/JS (1 year)
aws s3 cp ${S3_URI}/assets/ ${S3_URI}/assets/ \
    --recursive \
    --profile ${AWS_PROFILE} \
    --cache-control "public, max-age=31536000, immutable" \
    --metadata-directive REPLACE

# Short cache for HTML (1 hour)
aws s3 cp ${S3_URI}/ ${S3_URI}/ \
    --recursive \
    --profile ${AWS_PROFILE} \
    --exclude "*" \
    --include "*.html" \
    --cache-control "public, max-age=3600" \
    --metadata-directive REPLACE

echo -e "${GREEN}✓${NC} Cache headers updated"

# Step 3: Invalidate CloudFront cache
if [ -n "$CLOUDFRONT_DIST_ID" ]; then
    echo -e "${YELLOW}[3/3]${NC} Invalidating CloudFront cache..."

    aws cloudfront create-invalidation \
        --profile ${AWS_PROFILE} \
        --distribution-id ${CLOUDFRONT_DIST_ID} \
        --paths "${CF_PATH}"

    echo -e "${GREEN}✓${NC} CloudFront cache invalidated"
else
    echo -e "${YELLOW}[3/3]${NC} Skipping CloudFront invalidation (CLOUDFRONT_DIST_ID not set)"
fi

echo ""
echo -e "${GREEN}✅ Deployment complete!${NC}"
echo ""
echo "Site URL: https://360.elyx.life"
echo "S3 Path: ${S3_URI}/"
