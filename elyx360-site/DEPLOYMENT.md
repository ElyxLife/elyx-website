# Deployment Guide for Elyx 360 Website

## Quick Deploy Options

### 1. Netlify (Recommended - Easiest)

**Why Netlify?**
- Free SSL certificates
- Automatic deployments from Git
- Built-in CDN
- Easy custom domain setup
- Preview deployments for PRs

**Steps:**

1. Push this repository to GitHub
2. Go to [netlify.com](https://netlify.com) and sign up
3. Click "New site from Git"
4. Connect to your GitHub repository
5. Configure build settings:
   - **Build command:** `jekyll build`
   - **Publish directory:** `_site`
   - **Environment variable:** `JEKYLL_ENV=production`
6. Click "Deploy site"
7. Add custom domain `careers.elyx.life` in Domain settings
8. Update DNS with Netlify's nameservers or add CNAME record

**DNS Configuration:**
```
Type: CNAME
Name: careers
Value: [your-site].netlify.app
```

### 2. GitHub Pages (Free, Simple)

**Steps:**

1. Create a new repository (or use existing)
2. Push elyx360-site contents to repository
3. Go to repository Settings > Pages
4. Source: Deploy from main branch
5. Add `CNAME` file with domain:
   ```bash
   echo "careers.elyx.life" > CNAME
   ```
6. Update DNS:
   ```
   Type: CNAME
   Name: careers
   Value: [username].github.io
   ```

**Note:** GitHub Pages uses Jekyll natively, so no build step needed!

### 3. Vercel (Alternative)

**Steps:**

1. Go to [vercel.com](https://vercel.com)
2. Import Git repository
3. Framework preset: "Other"
4. Build command: `jekyll build`
5. Output directory: `_site`
6. Add domain in project settings

### 4. AWS S3 + CloudFront (Full Control)

**For production-grade deployment with AWS:**

**Build locally:**
```bash
JEKYLL_ENV=production bundle exec jekyll build
```

**Upload to S3:**
```bash
aws s3 sync _site/ s3://careers.elyx.life --delete
```

**CloudFront Configuration:**
1. Create CloudFront distribution
2. Origin: S3 bucket
3. SSL: Use ACM certificate for careers.elyx.life
4. Default root object: index.html
5. Error pages: Map 404 to /404.html

**DNS (Route 53 or other):**
```
Type: A (Alias)
Name: careers.elyx.life
Value: CloudFront distribution domain
```

## CI/CD Pipeline Examples

### GitHub Actions (Auto-deploy to S3)

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.1'
          bundler-cache: true

      - name: Build site
        run: JEKYLL_ENV=production bundle exec jekyll build

      - name: Deploy to S3
        uses: jakejarvis/s3-sync-action@master
        with:
          args: --delete
        env:
          AWS_S3_BUCKET: 'careers.elyx.life'
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          SOURCE_DIR: '_site'

      - name: Invalidate CloudFront
        run: |
          aws cloudfront create-invalidation \
            --distribution-id ${{ secrets.CLOUDFRONT_DIST_ID }} \
            --paths "/*"
```

### GitLab CI/CD

Create `.gitlab-ci.yml`:

```yaml
image: ruby:3.1

variables:
  JEKYLL_ENV: production

before_script:
  - bundle install

pages:
  stage: deploy
  script:
    - bundle exec jekyll build -d public
  artifacts:
    paths:
      - public
  only:
    - main
```

## Pre-Deployment Checklist

- [ ] Update `_config.yml` with production URL
- [ ] Generate and add images (see IMAGE_PROMPTS.md)
- [ ] Update team page with real team information
- [ ] Test all links and navigation
- [ ] Verify email addresses (currently careers@elyx.life)
- [ ] Test responsive design on mobile
- [ ] Set up analytics (Google Analytics, Plausible, etc.)
- [ ] Configure SSL certificate
- [ ] Set up error pages (404, 500)
- [ ] Test form submissions (newsletter)
- [ ] Enable GZIP compression
- [ ] Configure security headers

## Performance Optimization

### Before Deployment:

1. **Optimize images:**
   ```bash
   # Use ImageOptim or similar
   imageoptim assets/images/*
   ```

2. **Enable compression** in hosting platform

3. **Add caching headers:**
   - HTML: no-cache or short TTL
   - CSS/JS: 1 year cache
   - Images: 1 year cache

### Netlify Optimization:

Create `netlify.toml`:

```toml
[build]
  command = "jekyll build"
  publish = "_site"

[build.environment]
  JEKYLL_ENV = "production"

[[headers]]
  for = "/*"
  [headers.values]
    X-Frame-Options = "DENY"
    X-Content-Type-Options = "nosniff"
    Referrer-Policy = "no-referrer-when-downgrade"

[[headers]]
  for = "/assets/*"
  [headers.values]
    Cache-Control = "public, max-age=31536000, immutable"
```

## Monitoring & Analytics

### Add Google Analytics

In `_layouts/default.html`, add before `</head>`:

```html
<!-- Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'GA_MEASUREMENT_ID');
</script>
```

### Privacy-Focused Alternative: Plausible

```html
<script defer data-domain="careers.elyx.life" src="https://plausible.io/js/script.js"></script>
```

## Security Considerations

1. **SSL/TLS:** Always use HTTPS (automatic with Netlify/Vercel)
2. **Security headers:** See netlify.toml example above
3. **Content Security Policy:**
   ```
   Content-Security-Policy: default-src 'self'; script-src 'self' 'unsafe-inline'
   ```
4. **Regular updates:** Keep Jekyll and dependencies updated

## Cost Estimates

| Platform | Free Tier | Paid Features |
|----------|-----------|---------------|
| Netlify | 100GB bandwidth/month | More bandwidth, team features |
| Vercel | 100GB bandwidth/month | Enterprise features |
| GitHub Pages | Unlimited for public repos | N/A |
| AWS S3 + CloudFront | First 12 months | ~$1-5/month for small traffic |

## DNS Propagation

After configuring DNS, it may take 24-48 hours for changes to propagate globally. Test with:

```bash
dig careers.elyx.life
nslookup careers.elyx.life
```

## Rollback Strategy

### Netlify/Vercel
- Use the web interface to rollback to previous deployment
- Every deploy is saved and can be restored

### AWS S3
- Enable versioning on S3 bucket
- Keep backup of previous `_site` directory

### Git-based
- Revert commit and push:
  ```bash
  git revert HEAD
  git push origin main
  ```

## Support

For deployment issues:
- Netlify: https://docs.netlify.com
- Vercel: https://vercel.com/docs
- AWS: https://docs.aws.amazon.com
- Jekyll: https://jekyllrb.com/docs/

## Post-Deployment

1. Test website: https://careers.elyx.life
2. Submit to search engines:
   - Google Search Console
   - Bing Webmaster Tools
3. Set up monitoring/uptime checks
4. Monitor analytics for traffic
5. Set up application form handling (for job applications)

---

Need help? Contact the engineering team.
