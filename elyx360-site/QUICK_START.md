# Elyx 360 - Quick Start Guide

## 🎯 What You Have

A complete Jekyll website for 360.elyx.life with:
- ✅ 4 main pages (Home, Join Us, Team, Blog)
- ✅ 5 job listings from your JD
- ✅ 3 sample blog posts
- ✅ Complete design system (gold/black theme)
- ✅ Responsive, mobile-first design
- ✅ AWS S3 deployment script
- ✅ Docker development setup

## 🚀 Immediate Next Steps

### 1. Test Locally (Choose One)

**Option A: Docker (Easiest)**
```bash
cd elyx360-site
docker-compose up
```
Visit: http://localhost:4000

**Option B: Ruby**
```bash
cd elyx360-site
bundle config set --local path 'vendor/bundle'
bundle install
bundle exec jekyll serve
```
Visit: http://localhost:4000

### 2. Generate Images

Use the prompts in `IMAGE_PROMPTS.md` with:
- Midjourney
- DALL-E
- Stable Diffusion

Save to: `assets/images/`

### 3. Deploy to AWS S3

```bash
# 1. Edit deploy-to-s3.sh with your AWS details
nano deploy-to-s3.sh

# 2. Deploy
./deploy-to-s3.sh
```

## 📋 Before Going Live

### High Priority
- [ ] Generate hero images
- [ ] Configure deploy-to-s3.sh with CloudFront ID
- [ ] Test deployment to S3
- [ ] Verify careers@elyx.life email works
- [ ] Update DNS for 360.elyx.life

### Medium Priority
- [ ] Replace team page placeholders with real team
- [ ] Review and adjust job salary ranges
- [ ] Add Google Analytics or Plausible
- [ ] Test on mobile devices

### Optional
- [ ] Write more blog posts
- [ ] Set up GitHub Actions for auto-deploy
- [ ] Add application form service
- [ ] Create custom 404 page

## 📁 Key Files

| File | Purpose |
|------|---------|
| `deploy-to-s3.sh` | Deploy to AWS S3 |
| `AWS_DEPLOYMENT.md` | Complete AWS deployment guide |
| `IMAGE_PROMPTS.md` | AI prompts for generating images |
| `pages/join-us.html` | All job listings |
| `_sass/_variables.scss` | Design system colors/spacing |
| `docker-compose.yml` | Local development with Docker |

## 🎨 Customization

### Update Colors
Edit: `_sass/_variables.scss`

### Add/Edit Jobs
Edit: `pages/join-us.html`

### Add Blog Post
Create: `_posts/YYYY-MM-DD-title.md`

### Update Team
Edit: `pages/team.html`

## 🆘 Troubleshooting

**Can't build locally?**
→ Use Docker: `docker-compose up`

**Deployment fails?**
→ Check AWS_DEPLOYMENT.md

**Need help?**
→ Check README.md, SETUP.md, or PROJECT_OVERVIEW.md

## 📞 Support

- Technical: See SETUP.md and AWS_DEPLOYMENT.md
- Content: Update HTML files in pages/
- Questions: All docs are in the elyx360-site folder

---

**You're ready to launch! 🚀**

1. Generate images
2. Test locally
3. Deploy to S3
4. Point DNS to 360.elyx.life
