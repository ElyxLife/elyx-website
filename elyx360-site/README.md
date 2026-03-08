# Elyx 360 - Technology Careers Site

The technology engine behind Elyx. Built with Jekyll, themed after elyx.life, inspired by Supabase's developer-focused design.

## Overview

This is a static website showcasing Elyx 360's technology and engineering culture, with a primary focus on hiring talented engineers who want to build the future of AI-powered healthcare.

## Pages

1. **Home** - Technology showcase and mission overview
2. **Join Us** - All open engineering positions with detailed job descriptions
3. **Team** - Engineering team and culture (placeholder with dummy content)
4. **Blog** - Engineering insights and technical articles (includes 3 sample posts)

## Tech Stack

- **Jekyll 4.3** - Static site generator
- **Sass** - CSS preprocessing
- **Custom Design System** - Inspired by elyx.life (gold/black aesthetic) and Supabase (developer-focused)
- **Responsive Design** - Mobile-first approach

## Local Development

### Prerequisites

- Ruby 2.7 or higher
- Bundler gem

### Setup

```bash
cd elyx360-site

# Install dependencies
bundle install

# Run local development server
bundle exec jekyll serve

# Visit http://localhost:4000
```

### Build for Production

```bash
bundle exec jekyll build

# Output will be in _site/ directory
```

## Design System

### Colors

- **Primary Gold**: `#C9A961` - Main brand accent
- **Dark Background**: `#0A0A0A` - Main background
- **Section Background**: `#1A1A1A` - Card/section backgrounds
- **Text Primary**: `#FFFFFF` - Main text
- **Text Secondary**: `#B8B8B8` - Secondary text
- **Text Muted**: `#808080` - Muted text

### Typography

- **Font Family**: System fonts for optimal performance
- **Headings**: Bold, tight line-height, negative letter-spacing
- **Body**: 16px base, 1.6 line-height

### Components

- Navigation (fixed header with blur effect)
- Hero sections (large, centered, gold accents)
- Cards (hover effects, border animations)
- Buttons (primary gradient, secondary outline)
- Job cards (left border accent, structured layout)
- Footer (multi-column, links to all sections)

## Content Structure

```
elyx360-site/
├── _config.yml           # Jekyll configuration
├── _layouts/             # Page layouts
│   ├── default.html      # Base layout
│   └── post.html         # Blog post layout
├── _includes/            # Reusable components
│   ├── header.html       # Navigation
│   └── footer.html       # Footer
├── _sass/                # Stylesheets
│   ├── _variables.scss   # Design tokens
│   ├── _reset.scss       # CSS reset
│   └── _components.scss  # Component styles
├── _posts/               # Blog posts
├── pages/                # Static pages
├── assets/
│   ├── css/              # Compiled CSS
│   ├── js/               # JavaScript
│   └── images/           # Images (use IMAGE_PROMPTS.md to generate)
└── index.html            # Home page
```

## Images

We've included detailed AI image generation prompts in `IMAGE_PROMPTS.md`. Use these with:

- Midjourney
- DALL-E 3
- Stable Diffusion
- Adobe Firefly

Generate the images and place them in `assets/images/`.

## Deployment

### GitHub Pages

1. Push to GitHub
2. Enable GitHub Pages in repository settings
3. Set source to main branch

### Netlify

1. Connect repository to Netlify
2. Build command: `jekyll build`
3. Publish directory: `_site`

### Custom Server

1. Build with `bundle exec jekyll build`
2. Upload `_site/` contents to web server
3. Point domain (360.elyx.life) to deployment

## Customization

### Adding New Job Positions

Edit `pages/join-us.html` and add a new job card section following the existing pattern.

### Adding Blog Posts

Create new markdown files in `_posts/` with the naming convention:
```
YYYY-MM-DD-post-title.md
```

Front matter template:
```yaml
---
layout: post
title: "Your Post Title"
date: YYYY-MM-DD
author: "Author Name"
category: "Category"
excerpt: "Brief excerpt of the post"
---
```

### Updating Team Page

Replace placeholder content in `pages/team.html` with actual team member information and photos.

## SEO

The site includes:
- jekyll-seo-tag plugin
- Meta descriptions on all pages
- Semantic HTML structure
- OpenGraph tags

## Browser Support

- Chrome/Edge (latest)
- Firefox (latest)
- Safari (latest)
- Mobile browsers (iOS Safari, Chrome Mobile)

## Performance

- Minimal JavaScript (vanilla JS, no frameworks)
- CSS optimized with Sass
- System fonts (no web font loading)
- Lazy loading for images (when added)

## License

Proprietary - Elyx 360

## Contact

For questions about this website: [careers@elyx.life](mailto:careers@elyx.life)

---

Built with ❤️ by the Elyx 360 team
