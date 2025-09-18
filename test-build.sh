#!/bin/bash

# Exit on any error
set -e

echo "Starting local build test..."

# Build step: Copy shared content into each site
echo "Building sites with shared content..."

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

echo ""
echo "✅ Local build completed successfully!"
echo ""
echo "📁 Built files are in the 'build' directory:"
echo "   - build/elyx-life/ (contains all elyx-life files with injected content)"
echo "   - build/elyx-health/ (contains all elyx-health files with injected content)"
echo ""
echo "🌐 To test locally, you can:"
echo "   1. Open build/elyx-life/index.html in your browser"
echo "   2. Open build/elyx-life/support.html to see the support page"
echo "   3. Open build/elyx-life/privacy.html to see the privacy page"
echo "   4. Same for elyx-health directory"
echo ""
echo "🧹 To clean up: rm -rf build"