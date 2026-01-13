# Setup Instructions for Elyx 360 Website

## Quick Start

Since the system requires permissions for gem installation, you have two options:

### Option 1: Use rbenv/rvm (Recommended)

If you have rbenv or rvm installed:

```bash
cd elyx360-site

# Install dependencies to local vendor directory
bundle install --path vendor/bundle

# Run development server
bundle exec jekyll serve

# Visit http://localhost:4000
```

### Option 2: Use Docker (Easiest)

If you have Docker installed:

```bash
cd elyx360-site

# Run Jekyll in Docker
docker run --rm -v "$PWD:/srv/jekyll" -p 4000:4000 -it jekyll/jekyll:4 jekyll serve

# Visit http://localhost:4000
```

### Option 3: GitHub Pages (No Local Setup)

Simply push to GitHub and enable GitHub Pages:

1. Create new repository (or use existing)
2. Push elyx360-site contents to the repository
3. Go to Settings > Pages
4. Enable Pages from main branch
5. Site will be available at `https://[username].github.io/[repo-name]`

## Updating the Gemfile for Local Install

If you prefer to install gems locally without sudo, run this first:

```bash
cd elyx360-site
bundle config set --local path 'vendor/bundle'
bundle install
```

This will install all gems in the `vendor/bundle` directory within your project.

## Development Workflow

Once installed, you can:

```bash
# Start development server (with live reload)
bundle exec jekyll serve --livereload

# Build for production
bundle exec jekyll build

# Clean build artifacts
bundle exec jekyll clean
```

## Project Structure Verification

Run this to verify all files are in place:

```bash
cd elyx360-site
find . -type f -not -path "./vendor/*" -not -path "./.git/*" | head -20
```

You should see:
- _config.yml
- Gemfile
- index.html
- _layouts/
- _includes/
- _sass/
- pages/
- _posts/
- assets/

## Next Steps

1. **Install Dependencies** (choose one method above)
2. **Generate Images** - Use `IMAGE_PROMPTS.md` to create visuals with AI
3. **Test Locally** - Run `bundle exec jekyll serve`
4. **Customize Content** - Update team page with real team members
5. **Deploy** - Push to hosting platform of choice

## Deployment Options

### Netlify (Recommended)
1. Connect GitHub repository
2. Build command: `jekyll build`
3. Publish directory: `_site`
4. Add custom domain: `careers.elyx.life`

### Vercel
1. Import GitHub repository
2. Framework preset: Jekyll
3. Build command: `jekyll build`
4. Output directory: `_site`

### AWS S3 + CloudFront
1. Build locally: `bundle exec jekyll build`
2. Upload `_site/` to S3 bucket
3. Configure CloudFront distribution
4. Point careers.elyx.life to CloudFront

### GitHub Pages
1. Push to GitHub
2. Enable Pages in repository settings
3. Custom domain: Add CNAME file with `careers.elyx.life`
4. Update DNS to point to GitHub Pages

## Troubleshooting

### "Bundle install requires sudo"
Use Option 1 above with `--path vendor/bundle` flag.

### "Command not found: jekyll"
Make sure to use `bundle exec jekyll` instead of just `jekyll`.

### "Sass compilation failed"
Check that all .scss files in `_sass/` have correct syntax.

### CSS not loading
Make sure `main.scss` has the front matter `---` at the top.

## Support

For issues with the website setup, contact the development team.
