#!/bin/bash

# Elyx 360 - AWS S3 Deploy Script
# Uploads _site/ to S3 and invalidates CloudFront cache.
# Run build.sh first to generate _site/.

set -e

# Configuration — set these via environment variables or override below
S3_BUCKET="${S3_BUCKET:-}"
S3_PATH=""             # Root of bucket (no subfolder)
CLOUDFRONT_DIST_ID="${CLOUDFRONT_DIST_ID:-}"
AWS_PROFILE="${AWS_PROFILE:-default}"

if [ -z "$S3_BUCKET" ]; then
    echo "❌ S3_BUCKET environment variable is not set."
    exit 1
fi

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

# Step 1: Sync static assets with long cache (1 year)
echo -e "${YELLOW}[1/3]${NC} Syncing assets to S3: ${S3_URI}/assets/"

aws s3 sync _site/assets/ ${S3_URI}/assets/ \
    --profile ${AWS_PROFILE} \
    --delete \
    --cache-control "public, max-age=31536000, immutable" \
    --exclude ".DS_Store"

echo -e "${GREEN}✓${NC} Assets synced"

# Step 2: Sync everything else with short cache (1 hour)
echo -e "${YELLOW}[2/3]${NC} Syncing remaining files to S3: ${S3_URI}/"

aws s3 sync _site/ ${S3_URI}/ \
    --profile ${AWS_PROFILE} \
    --delete \
    --cache-control "public, max-age=3600" \
    --exclude ".git/*" \
    --exclude ".DS_Store" \
    --exclude "assets/*"

echo -e "${GREEN}✓${NC} Files synced"

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
