# AWS S3 Deployment Guide - Elyx 360

This site deploys to AWS S3, similar to the existing elyx-life and elyx-health folders.

## Quick Deploy

```bash
./deploy-to-s3.sh
```

## Configuration

### 1. Update Deployment Script

Edit `deploy-to-s3.sh` and configure:

```bash
S3_BUCKET="elyx-life"           # Your S3 bucket name
S3_PATH="elyx360"                # Folder path (e.g., elyx360/)
CLOUDFRONT_DIST_ID="E1234..."    # Your CloudFront distribution ID
AWS_PROFILE="default"            # AWS CLI profile to use
```

### 2. AWS CLI Setup

If not already configured:

```bash
# Install AWS CLI (if needed)
brew install awscli  # macOS
# or
pip install awscli

# Configure credentials
aws configure --profile default
# Enter your:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region (e.g., us-east-1)
# - Output format (json)
```

## S3 Bucket Structure

Following the same pattern as existing sites:

```
s3://elyx-life/
├── elyx-life/          # Main site (existing)
├── elyx-health/        # Health site (existing)
└── elyx360/            # New careers site
    ├── index.html
    ├── join-us/
    ├── team/
    ├── blog/
    └── assets/
```

## Deployment Steps

### Manual Deployment

```bash
# 1. Build the site
JEKYLL_ENV=production bundle exec jekyll build

# 2. Sync to S3
aws s3 sync _site/ s3://elyx-life/elyx360/ \
    --delete \
    --cache-control "public, max-age=3600"

# 3. Invalidate CloudFront (if using CDN)
aws cloudfront create-invalidation \
    --distribution-id E1234567890ABC \
    --paths "/elyx360/*"
```

### Automated Deployment

Use the provided script:

```bash
./deploy-to-s3.sh
```

The script:
1. ✅ Cleans previous build
2. ✅ Builds Jekyll site with production settings
3. ✅ Syncs to S3 with --delete flag
4. ✅ Sets appropriate cache headers
5. ✅ Invalidates CloudFront cache

## DNS Configuration

Point `360.elyx.life` to your CloudFront distribution or S3 bucket:

### Option 1: CloudFront (Recommended)

**Route 53:**
```
Type: A (Alias)
Name: 360.elyx.life
Value: CloudFront distribution (e.g., d111111abcdef8.cloudfront.net)
```

**Other DNS:**
```
Type: CNAME
Name: careers
Value: d111111abcdef8.cloudfront.net
```

### Option 2: S3 Direct

```
Type: CNAME
Name: careers
Value: elyx-life.s3-website-us-east-1.amazonaws.com
```

**Note:** S3 website endpoint depends on region

## CloudFront Configuration

If using the same CloudFront distribution as elyx-life:

### Origin Configuration
- **Origin Domain:** elyx-life.s3.amazonaws.com
- **Origin Path:** /elyx360 (if using subfolder)

### Behavior Rules
Add a path pattern for `/elyx360/*`:
- **Path Pattern:** `/elyx360/*`
- **Origin:** elyx-life S3 bucket
- **Viewer Protocol:** Redirect HTTP to HTTPS
- **Allowed HTTP Methods:** GET, HEAD, OPTIONS
- **Cache Policy:** CachingOptimized (or custom)
- **Compress Objects:** Yes

### Alternative: Subdomain Origin
If 360.elyx.life has its own behavior:
- **Path Pattern:** `*`
- **Host Header:** 360.elyx.life
- Same cache settings as above

## Cache Configuration

The deployment script sets these cache headers:

```bash
# HTML files: 1 hour cache
Cache-Control: public, max-age=3600

# CSS/JS/Images: 1 year cache (immutable)
Cache-Control: public, max-age=31536000, immutable
```

### Manual Cache Control

Update cache headers:

```bash
# Long cache for assets
aws s3 cp s3://elyx-life/elyx360/assets/ s3://elyx-life/elyx360/assets/ \
    --recursive \
    --cache-control "public, max-age=31536000, immutable" \
    --metadata-directive REPLACE

# Short cache for HTML
aws s3 cp s3://elyx-life/elyx360/ s3://elyx-life/elyx360/ \
    --recursive \
    --exclude "*" \
    --include "*.html" \
    --cache-control "public, max-age=3600" \
    --metadata-directive REPLACE
```

## CI/CD with GitHub Actions

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to AWS S3

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.1'
          bundler-cache: true

      - name: Build Jekyll site
        run: JEKYLL_ENV=production bundle exec jekyll build

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Deploy to S3
        run: |
          aws s3 sync _site/ s3://elyx-life/elyx360/ \
            --delete \
            --cache-control "public, max-age=3600"

      - name: Set cache headers for assets
        run: |
          aws s3 cp s3://elyx-life/elyx360/assets/ s3://elyx-life/elyx360/assets/ \
            --recursive \
            --cache-control "public, max-age=31536000, immutable" \
            --metadata-directive REPLACE

      - name: Invalidate CloudFront
        run: |
          aws cloudfront create-invalidation \
            --distribution-id ${{ secrets.CLOUDFRONT_DIST_ID }} \
            --paths "/elyx360/*"
```

**Required GitHub Secrets:**
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `CLOUDFRONT_DIST_ID`

## Troubleshooting

### Build Issues

**Problem:** Jekyll build fails
```bash
# Install dependencies
bundle install

# Try building locally
bundle exec jekyll build
```

**Problem:** Ruby version mismatch
```bash
# Use Docker instead
docker run --rm -v "$PWD:/srv/jekyll" jekyll/jekyll:4 jekyll build
```

### Deployment Issues

**Problem:** AWS credentials not found
```bash
# Check AWS configuration
aws configure list

# Test credentials
aws s3 ls s3://elyx-life/
```

**Problem:** Permission denied
```bash
# Verify IAM permissions for:
# - s3:PutObject
# - s3:DeleteObject
# - s3:ListBucket
# - cloudfront:CreateInvalidation (if using CloudFront)
```

**Problem:** Files uploaded but not visible
```bash
# Check S3 bucket policy allows public read
# Verify CloudFront is pointing to correct origin
# Check if files exist:
aws s3 ls s3://elyx-life/elyx360/ --recursive
```

### Cache Issues

**Problem:** Old content still showing
```bash
# Force CloudFront invalidation
aws cloudfront create-invalidation \
    --distribution-id E1234567890ABC \
    --paths "/elyx360/*" "/"

# Check invalidation status
aws cloudfront get-invalidation \
    --distribution-id E1234567890ABC \
    --id INVALIDATION_ID
```

## Performance Optimization

### 1. Enable GZIP Compression

CloudFront automatically compresses if:
- **Compress Objects Automatically:** Enabled in behavior settings
- File types: text/html, text/css, application/javascript, etc.

### 2. Optimize Images

Before deployment:
```bash
# Install image optimization tools
brew install imageoptim-cli

# Optimize images
imageoptim assets/images/*
```

### 3. Minimize CSS/JS

Add to build process:
```bash
# Install minification tools
npm install -g clean-css-cli uglify-js

# Minify CSS
cleancss -o assets/css/main.min.css assets/css/main.css

# Minify JS
uglifyjs assets/js/main.js -o assets/js/main.min.js
```

## Security

### S3 Bucket Policy

The bucket should have a policy allowing CloudFront access:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowCloudFrontAccess",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudfront.amazonaws.com"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::elyx-life/elyx360/*",
      "Condition": {
        "StringEquals": {
          "AWS:SourceArn": "arn:aws:cloudfront::ACCOUNT-ID:distribution/DIST-ID"
        }
      }
    }
  ]
}
```

### HTTPS Only

Ensure CloudFront is configured to:
- **Viewer Protocol Policy:** Redirect HTTP to HTTPS
- **SSL Certificate:** ACM certificate for 360.elyx.life

## Monitoring

### CloudWatch Alarms

Set up alarms for:
- S3 bucket size
- CloudFront error rates (4xx, 5xx)
- Cache hit ratio

### Access Logs

Enable CloudFront logging:
- **Logging:** Enabled
- **Log Bucket:** separate S3 bucket for logs
- **Log Prefix:** elyx360/

## Cost Optimization

Estimated AWS costs for low-medium traffic:

| Service | Monthly Cost |
|---------|--------------|
| S3 Storage (1GB) | ~$0.02 |
| S3 Requests | ~$0.01 |
| CloudFront (10GB transfer) | ~$0.85 |
| **Total** | **~$0.88/month** |

Tips to reduce costs:
- Use CloudFront caching effectively
- Set appropriate cache durations
- Compress files
- Optimize images

## Rollback

To rollback to a previous version:

```bash
# 1. Enable S3 versioning (if not already)
aws s3api put-bucket-versioning \
    --bucket elyx-life \
    --versioning-configuration Status=Enabled

# 2. List versions
aws s3api list-object-versions \
    --bucket elyx-life \
    --prefix elyx360/

# 3. Restore specific version
aws s3api copy-object \
    --bucket elyx-life \
    --copy-source elyx-life/elyx360/index.html?versionId=VERSION_ID \
    --key elyx360/index.html

# 4. Invalidate CloudFront
aws cloudfront create-invalidation \
    --distribution-id E1234567890ABC \
    --paths "/elyx360/*"
```

## Support

For AWS-specific issues:
- Check AWS CloudWatch logs
- Review CloudFront access logs
- Contact AWS Support (if on support plan)

---

**Next Steps:**
1. Configure `deploy-to-s3.sh` with your AWS details
2. Test deployment: `./deploy-to-s3.sh`
3. Verify: https://360.elyx.life
4. Set up GitHub Actions for automated deployments
