# Elyx 360 - Technology Careers Site

The technology engine behind Elyx. Built with Jekyll, themed after elyx.life.

**Target Audience:** Engineers interested in AI, healthcare automation, and longevity technology.

## Quick Start

### Option A: Docker (Easiest)

```bash
cd elyx360-site
docker-compose up
```

Visit: http://localhost:4000

### Option B: Local Ruby

```bash
cd elyx360-site
bundle config set --local path 'vendor/bundle'
bundle install
bundle exec jekyll serve
```

Visit: http://localhost:4000

### Build for Production

```bash
JEKYLL_ENV=production bundle exec jekyll build
# Output in _site/
```

## Pages

1. **Home** (`/`) — Technology showcase, healthspan formula, engineering philosophy, hiring CTA
2. **Join Us** (`/join-us`) — 5 job listings with detailed descriptions, culture, application process
3. **Team** (`/team`) — Engineering team and culture (placeholder with dummy content)
4. **Blog** (`/blog`) — 3 sample technical posts with RSS feed

## Project Structure

```
elyx360-site/
├── _config.yml              # Jekyll configuration
├── _layouts/                # Page templates
│   ├── default.html         # Base layout
│   └── post.html            # Blog post layout
├── _includes/               # Reusable components
│   ├── header.html          # Navigation bar
│   └── footer.html          # Footer with links
├── _sass/                   # Stylesheets (SCSS)
│   ├── _variables.scss      # Design tokens (colors, spacing)
│   ├── _reset.scss          # CSS reset
│   └── _components.scss     # All component styles
├── _posts/                  # Blog posts (Markdown)
├── pages/                   # Static pages
│   ├── join-us.html         # Job listings
│   ├── team.html            # Team page
│   └── blog.html            # Blog index
├── assets/
│   ├── css/main.scss        # Main stylesheet
│   ├── js/main.js           # Interactive features
│   └── images/              # Generated images (see IMAGE_PROMPTS.md)
├── deploy-to-s3.sh          # AWS S3 deployment script
├── build.sh                 # Build script
├── docker-compose.yml       # Docker development setup
└── IMAGE_PROMPTS.md         # AI image generation prompts
```

## Design System

| Token | Value | Usage |
|-------|-------|-------|
| Primary Gold | `#C9A961` | Brand accent, CTAs, highlights |
| Dark Background | `#0A0A0A` | Main background |
| Section Background | `#1A1A1A` | Cards, sections |
| Text Primary | `#FFFFFF` | Headings |
| Text Secondary | `#B8B8B8` | Body text |
| Text Muted | `#808080` | Meta information |

**Typography:** System font stack, 16px base, 1.6 line-height. Headings use tight line-height with negative letter-spacing.

**Components:** Fixed nav with blur, hero sections, hover cards, gradient/outline buttons, job cards, responsive grid, multi-column footer.

## Customization

### Add/Edit Job Positions
Edit `pages/join-us.html` — copy an existing job card section.

### Add a Blog Post
Create `_posts/YYYY-MM-DD-post-slug.md`:

```yaml
---
layout: post
title: "Your Post Title"
date: YYYY-MM-DD
author: "Author Name"
category: "Category"
excerpt: "Brief excerpt"
---
```

### Update Colors
Edit `_sass/_variables.scss`.


## Brand Voice
- Direct and technical, mission-driven, AI-native
- Honest about challenges, excited about impact
- "Build guardrails for AI to build features" — not "Synergize cross-functional paradigms"

## TODO
- [ ] Replace team page placeholders with real team
- [ ] Review and adjust job salary ranges
- [ ] Add analytics (Google Analytics or Plausible)
- [ ] Test on mobile devices
- [ ] Write blog posts
- [ ] Set up GitHub Actions for auto-deploy
- [ ] Add application form service
- [ ] Create custom 404 page

## Deployment

```bash
./build.sh          # Build _site/
./deploy-to-s3.sh   # Sync to S3 + invalidate CloudFront
```

Configuration is at the top of `deploy-to-s3.sh`.

## Troubleshooting

**Bundle install requires sudo?**
Use `bundle config set --local path 'vendor/bundle'` then `bundle install`.

**Command not found: jekyll?**
Use `bundle exec jekyll` instead of just `jekyll`.

**Can't build locally?**
Use Docker: `docker-compose up`

**Sass compilation failed?**
Check that all `.scss` files in `_sass/` have correct syntax.

**CSS not loading?**
Make sure `main.scss` has the front matter `---` at the top.

**AWS credentials not found?**
Run `aws configure list` to check, `aws s3 ls s3://360-elyx-life-static/` to test.

**Old content still showing after deploy?**
Force CloudFront invalidation: `aws cloudfront create-invalidation --distribution-id E3FDAE39VEYN3X --paths "/*"`

## SEO

Includes jekyll-seo-tag plugin, meta descriptions, semantic HTML, OpenGraph tags, sitemap.xml, and robots.txt.

## License

Proprietary - Elyx 360
