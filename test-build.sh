#!/bin/bash

# Test script to verify the build process works correctly
echo "Testing build process..."

# Create build directories
mkdir -p build/elyx-life
mkdir -p build/elyx-health

# Copy elyx-life content to build directory
cp -r elyx-life/* build/elyx-life/

# Copy elyx-health content to build directory  
cp -r elyx-health/* build/elyx-health/

# Copy shared privacy content into each site's privacy.html
if [ -f shared/privacy-statement.html ]; then
    echo "Injecting shared privacy content..."
    
    # For elyx-life
    sed -i.bak '/<div class="content" id="privacy-content">/,/<\/div>/c\
      <div class="content" id="privacy-content">\
        <!-- Privacy content injected during build -->\
      </div>' build/elyx-life/privacy.html
    
    # Insert the shared content into elyx-life
    awk '/<!-- Privacy content injected during build -->/ { system("cat shared/privacy-statement.html"); next } 1' build/elyx-life/privacy.html > build/elyx-life/privacy.html.tmp && mv build/elyx-life/privacy.html.tmp build/elyx-life/privacy.html
    
    # For elyx-health
    sed -i.bak '/<div class="content" id="privacy-content">/,/<\/div>/c\
      <div class="content" id="privacy-content">\
        <!-- Privacy content injected during build -->\
      </div>' build/elyx-health/privacy.html
    
    # Insert the shared content into elyx-health
    awk '/<!-- Privacy content injected during build -->/ { system("cat shared/privacy-statement.html"); next } 1' build/elyx-health/privacy.html > build/elyx-health/privacy.html.tmp && mv build/elyx-health/privacy.html.tmp build/elyx-health/privacy.html
    
    # Remove the JavaScript fetch code from both files
    sed -i.bak '/<script>/,/<\/script>/d' build/elyx-life/privacy.html
    sed -i.bak '/<script>/,/<\/script>/d' build/elyx-health/privacy.html
    
    # Clean up backup files
    rm -f build/elyx-life/privacy.html.bak build/elyx-health/privacy.html.bak
    
    echo "Privacy content successfully injected into both sites"
    
    # Verify the content was injected
    echo ""
    echo "Verifying build results..."
    echo "elyx-life privacy.html size: $(wc -c < build/elyx-life/privacy.html) bytes"
    echo "elyx-health privacy.html size: $(wc -c < build/elyx-health/privacy.html) bytes"
    echo "shared privacy-statement.html size: $(wc -c < shared/privacy-statement.html) bytes"
    
    # Check if privacy content is present
    if grep -q "Elyx - Data Privacy and Security Policy" build/elyx-life/privacy.html; then
        echo "✅ Privacy content found in elyx-life/privacy.html"
    else
        echo "❌ Privacy content NOT found in elyx-life/privacy.html"
    fi
    
    if grep -q "Elyx - Data Privacy and Security Policy" build/elyx-health/privacy.html; then
        echo "✅ Privacy content found in elyx-health/privacy.html"
    else
        echo "❌ Privacy content NOT found in elyx-health/privacy.html"
    fi
    
    # Check if JavaScript was removed
    if grep -q "fetch(" build/elyx-life/privacy.html; then
        echo "❌ JavaScript fetch code still present in elyx-life/privacy.html"
    else
        echo "✅ JavaScript fetch code removed from elyx-life/privacy.html"
    fi
    
    if grep -q "fetch(" build/elyx-health/privacy.html; then
        echo "❌ JavaScript fetch code still present in elyx-health/privacy.html"
    else
        echo "✅ JavaScript fetch code removed from elyx-health/privacy.html"
    fi
    
else
    echo "Warning: shared/privacy-statement.html not found"
fi

echo ""
echo "Build test completed! Check the build/ directory for results."
echo "To clean up, run: rm -rf build/" 