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

# Build step: Copy shared privacy content into each site
echo "Building sites with shared privacy content..."

# Create build directories
mkdir -p build/elyx-life
mkdir -p build/elyx-health

# Copy elyx-life content to build directory
cp -r elyx-life/* build/elyx-life/

# Copy elyx-health content to build directory  
cp -r elyx-health/* build/elyx-health/

# Define shared content files to inject
# Format: "shared_file:target_file:content_id:description"
SHARED_CONTENT=(
    "shared/privacy-statement.html:privacy.html:privacy-content:privacy content"
    "shared/support-content.html:support.html:support-content:support content"
)

# Function to inject shared content into a site
inject_shared_content() {
    local shared_file="$1"
    local target_file="$2"
    local content_id="$3"
    local description="$4"
    local site="$5"
    
    if [ -f "$shared_file" ]; then
        echo "Injecting shared $description into $site/$target_file..."
        
        # Reset the content div to placeholder
        sed -i.bak "/<div class=\"content\" id=\"$content_id\">/,/<\/div>/c\\
      <div class=\"content\" id=\"$content_id\">\\
        <!-- $description injected during build -->\\
      </div>" "build/$site/$target_file"
        
        # Insert the shared content
        awk "/<!-- $description injected during build -->/ { system(\"cat $shared_file\"); next } 1" "build/$site/$target_file" > "build/$site/$target_file.tmp" && mv "build/$site/$target_file.tmp" "build/$site/$target_file"
        
        # Clean up backup file
        rm -f "build/$site/$target_file.bak"
        
        echo "$description successfully injected into $site"
    else
        echo "Warning: $shared_file not found"
    fi
}

# Inject all shared content
echo "Injecting shared content into both sites..."
for content_config in "${SHARED_CONTENT[@]}"; do
    IFS=':' read -r shared_file target_file content_id description <<< "$content_config"
    
    # Inject into both sites
    inject_shared_content "$shared_file" "$target_file" "$content_id" "$description" "elyx-life"
    inject_shared_content "$shared_file" "$target_file" "$content_id" "$description" "elyx-health"
done

# Deploy elyx.life
echo "Deploying to elyx.life..."
gcloud storage rsync -r \
  --cache-control="public, max-age=31536000" \
  --exclude=".*" \
  --exclude="*.DS_Store" \
  --exclude="__MACOSX" \
  --exclude="Thumbs.db" \
  --exclude="desktop.ini" \
  build/elyx-life gs://elyx.life

# Deploy elyx.health
echo "Deploying to elyx.health..."
gcloud storage rsync -r \
  --cache-control="public, max-age=31536000" \
  --exclude=".*" \
  --exclude="*.DS_Store" \
  --exclude="__MACOSX" \
  --exclude="Thumbs.db" \
  --exclude="desktop.ini" \
  build/elyx-health gs://elyx.health

# Clean up build directory
echo "Cleaning up build directory..."
rm -rf build

echo "Deployment completed successfully!" 