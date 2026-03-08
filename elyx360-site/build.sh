#!/bin/bash

# Elyx 360 - Jekyll Build Script

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🔨 Building Elyx 360 site..."
echo ""

# Step 1: Clean previous build
echo -e "${YELLOW}[1/2]${NC} Cleaning previous build..."
if [ -d "_site" ]; then
    rm -rf _site
fi

# Step 2: Build Jekyll site for production
echo -e "${YELLOW}[2/2]${NC} Building Jekyll site..."
JEKYLL_ENV=production bundle exec jekyll build

if [ ! -d "_site" ]; then
    echo "❌ Build failed - _site directory not found"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ Build complete!${NC} Output in _site/"
