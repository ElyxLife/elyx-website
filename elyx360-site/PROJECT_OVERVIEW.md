# Elyx 360 Website - Project Overview

## 🎯 Project Summary

A modern, developer-focused Jekyll website showcasing Elyx 360's technology and engineering culture. Built for `careers.elyx.life`, this site serves as both a technology showcase and recruiting platform.

**Design Inspiration:**
- **elyx.life** - Gold/black aesthetic, minimalist premium feel
- **Supabase** - Developer-focused content, technical credibility

**Target Audience:** Engineers interested in AI, healthcare automation, and longevity technology

## 📁 Project Structure

```
elyx360-site/
├── _config.yml              # Jekyll configuration
├── _includes/               # Reusable components
│   ├── header.html          # Navigation bar
│   └── footer.html          # Footer with links
├── _layouts/                # Page templates
│   ├── default.html         # Base layout
│   └── post.html            # Blog post layout
├── _sass/                   # Stylesheets (SCSS)
│   ├── _variables.scss      # Design tokens (colors, spacing, etc.)
│   ├── _reset.scss          # CSS reset
│   └── _components.scss     # All component styles
├── _posts/                  # Blog posts (Markdown)
│   ├── 2026-01-10-building-ai-healthcare-infrastructure.md
│   ├── 2026-01-05-ai-augmented-engineering.md
│   └── 2025-12-28-why-healthcare-needs-ai.md
├── pages/                   # Static pages
│   ├── join-us.html         # Job listings
│   ├── team.html            # Team page (placeholder)
│   └── blog.html            # Blog index
├── assets/
│   ├── css/
│   │   └── main.scss        # Main stylesheet (imports all SCSS)
│   ├── js/
│   │   └── main.js          # Interactive features
│   └── images/              # (Empty - use IMAGE_PROMPTS.md to generate)
├── index.html               # Home page
├── Gemfile                  # Ruby dependencies
├── docker-compose.yml       # Docker development setup
├── start-dev.sh             # Quick start script
├── README.md                # Project documentation
├── SETUP.md                 # Local development setup
├── DEPLOYMENT.md            # Deployment guide
└── IMAGE_PROMPTS.md         # AI image generation prompts
```

## 🎨 Design System

### Color Palette
- **Primary Gold:** `#C9A961` - Brand accent, CTAs, highlights
- **Dark Background:** `#0A0A0A` - Main background
- **Section Background:** `#1A1A1A` - Cards, sections
- **Text Primary:** `#FFFFFF` - Headings, important text
- **Text Secondary:** `#B8B8B8` - Body text
- **Text Muted:** `#808080` - Meta information

### Typography
- **Font:** System font stack (optimized performance)
- **Headings:** Bold, tight line-height, negative letter-spacing
- **Body:** 16px base, 1.6 line-height

### Components
- Fixed navigation with blur effect
- Hero sections with large typography
- Card components with hover effects
- Gradient buttons (primary) and outline buttons (secondary)
- Job cards with structured layout
- Responsive grid system

## 📄 Pages

### 1. Home (`/`)
**Purpose:** Technology showcase and mission overview

**Sections:**
- Hero: "The Technology Behind Maximum Healthspan"
- Healthspan formula
- Technology stack (6 cards)
- Technical challenges (3 cards)
- Engineering philosophy
- Hiring CTA

**Key Messages:**
- AI-powered healthcare automation
- HIPAA-compliant infrastructure
- High-velocity development
- Mission-critical work

### 2. Join Us (`/join-us`)
**Purpose:** Detailed job listings and application info

**Content:**
- 5 job positions:
  1. Infrastructure Architect ($6-10k SGD/mo)
  2. Full-Stack Engineer ($4-10k SGD/mo)
  3. Front-End Framework Engineer ($4-10k SGD/mo)
  4. Product Engineer ($4-10k SGD/mo)
  5. AI Systems Engineer (Competitive)
- Why join Elyx 360 (6 value propositions)
- The Vibe (culture)
- Application process (3 questions)

**CTAs:**
- Apply buttons for each position
- Email: careers@elyx.life

### 3. Team (`/team`)
**Purpose:** Showcase engineering team (placeholder)

**Content:**
- Team philosophy
- Leadership team (6 placeholder profiles)
- Engineering culture (6 aspects)
- Hiring CTA

**Status:** Placeholder - ready for real team data

### 4. Blog (`/blog`)
**Purpose:** Technical content and thought leadership

**Sample Posts:**
1. "Building AI-First Healthcare Infrastructure"
2. "AI-Augmented Engineering: 10x Development Velocity"
3. "Why Healthcare is the Ultimate AI Challenge"

**Features:**
- Post excerpts with read more
- Date, author, category metadata
- Newsletter signup (placeholder)

## 🚀 Getting Started

### Prerequisites
- Ruby 2.7+ OR Docker

### Quick Start Options

**Option 1: Docker (Recommended)**
```bash
cd elyx360-site
./start-dev.sh
# or
docker-compose up
```
Visit: http://localhost:4000

**Option 2: Local Ruby**
```bash
cd elyx360-site
bundle config set --local path 'vendor/bundle'
bundle install
bundle exec jekyll serve
```
Visit: http://localhost:4000

**Option 3: Direct Deploy**
- Push to GitHub
- Enable GitHub Pages
- No local setup needed!

## 🎯 Next Steps

### Before Launch:

1. **Generate Images** (Priority: High)
   - Use prompts in `IMAGE_PROMPTS.md`
   - Tools: Midjourney, DALL-E, Stable Diffusion
   - Place in `assets/images/`
   - Update HTML to reference images

2. **Update Team Page** (Priority: Medium)
   - Replace placeholder content
   - Add real team member photos and bios
   - Update stats if needed

3. **Configure Email** (Priority: High)
   - Verify careers@elyx.life is set up
   - Consider form service for applications:
     - Netlify Forms (free)
     - Formspree
     - SendGrid

4. **Add Analytics** (Priority: Medium)
   - Google Analytics or
   - Plausible (privacy-focused)
   - See DEPLOYMENT.md for integration

5. **SEO Optimization** (Priority: Medium)
   - Add meta descriptions (already templated)
   - Create sitemap.xml
   - Add robots.txt
   - Submit to Google Search Console

6. **Performance** (Priority: Low)
   - Optimize images
   - Enable GZIP compression
   - Add caching headers
   - Test with Lighthouse

### Content Updates:

- **Home page:** Verify all statistics and claims
- **Job listings:** Update salary ranges as needed
- **Blog posts:** Add more content over time
- **Team page:** Add real team members

## 🔧 Customization

### Adding a New Job Position

Edit `pages/join-us.html`, copy a job card section:

```html
<div class="job-card">
  <div class="job-header">
    <h3>Job Title</h3>
    <div class="job-meta">
      <span>📍 Location</span>
      <span>💰 Compensation</span>
    </div>
  </div>
  <div class="job-description">
    <!-- Content here -->
  </div>
  <a href="mailto:careers@elyx.life?subject=Application: Job Title" class="btn btn-primary">Apply</a>
</div>
```

### Adding a Blog Post

Create `_posts/YYYY-MM-DD-post-slug.md`:

```markdown
---
layout: post
title: "Your Post Title"
date: YYYY-MM-DD
author: "Author Name"
category: "Category"
excerpt: "Brief excerpt"
---

Your content here...
```

### Updating Colors

Edit `_sass/_variables.scss`:

```scss
$color-primary: #C9A961;  // Change this
```

## 📊 Site Statistics

- **Pages:** 4 main pages
- **Blog posts:** 3 sample posts
- **Job listings:** 5 positions
- **Components:** 10+ reusable components
- **Lines of code:** ~2,500 (HTML, SCSS, JS)

## 🛠 Technology Stack

- **Generator:** Jekyll 4.3
- **Language:** Ruby
- **Styling:** Sass/SCSS
- **JavaScript:** Vanilla JS (no frameworks)
- **Deployment:** Netlify/Vercel/GitHub Pages recommended
- **Version Control:** Git

## 📝 Key Features

✅ Fully responsive (mobile-first)
✅ Dark theme optimized
✅ Smooth scrolling navigation
✅ Animated cards on scroll
✅ SEO optimized
✅ Fast loading (no heavy dependencies)
✅ Accessible HTML structure
✅ RSS feed ready
✅ Blog functionality
✅ Easy to customize

## 🎨 Brand Voice

**Tone:**
- Direct and technical
- Mission-driven
- AI-native and future-focused
- Honest about challenges
- Excited about impact

**Avoid:**
- Generic corporate speak
- Over-promising
- Medical jargon (keep accessible)
- Condescension toward non-engineers

**Examples:**
- ✅ "Build guardrails for AI to build features"
- ✅ "Your code impacts how long people live"
- ✅ "We automate the impossible"
- ❌ "Synergize cross-functional paradigms"
- ❌ "Best-in-class enterprise solutions"

## 📞 Support & Contact

- **Technical issues:** Refer to SETUP.md and DEPLOYMENT.md
- **Content questions:** Contact product/marketing team
- **Recruitment:** careers@elyx.life

## 📜 License

Proprietary - Elyx 360

---

**Built with:** Jekyll, Sass, and a vision for the future of healthcare.

**Ready for:** Deployment to careers.elyx.life

**Status:** ✅ Production-ready (pending images and team content)
