#!/bin/bash

echo "🚀 Starting Elyx 360 Development Server..."
echo ""

# Check if Docker is available
if command -v docker &> /dev/null; then
    echo "✅ Docker found. Starting with Docker Compose..."
    docker-compose up
else
    echo "⚠️  Docker not found."
    echo ""
    echo "Please install Docker or use one of these alternatives:"
    echo ""
    echo "1. Install Docker Desktop: https://www.docker.com/products/docker-desktop"
    echo ""
    echo "2. Use Bundle (if you have rbenv/rvm):"
    echo "   bundle config set --local path 'vendor/bundle'"
    echo "   bundle install"
    echo "   bundle exec jekyll serve"
    echo ""
    echo "3. Deploy directly to GitHub Pages (no local setup needed)"
    echo ""
fi
