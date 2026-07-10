# Elyx Life — Marketing Site

Static marketing site for [elyx.life](https://elyx.life). Source pages are `.dc.html` files with client-side hydration via `support.js`.

## Local preview

```bash
cd elyx-life-2
python3 -m http.server 8080
# or: npx serve .
```

Open http://localhost:8080 — pages require JavaScript (React loads from unpkg at runtime).

## Structure

```
elyx-life-2/
  index.html          # Home (CloudFront default root)
  *.dc.html           # Site pages (keep filenames — internal links depend on them)
  support -> Support.dc.html   # Local clean-URL alias (/support)
  privacy -> Privacy.dc.html   # Local clean-URL alias (/privacy)
  support.js          # DC runtime (generated bundle)
  image-slot.js
  assets/             # Local images
  robots.txt
  sitemap.xml
```

Clean URLs `/support` and `/privacy` reuse `Support.dc.html` and `Privacy.dc.html` (symlinks locally; deploy uploads the same files to those S3 keys).

## Deploy

Deployments are **manual** via GitHub Actions (no push trigger):

| Workflow | Environment | URL |
|----------|-------------|-----|
| Deploy Elyx Life 2 (Staging) | `staging` | https://www.elyx.dev |
| Deploy Elyx Life 2 (Production) | `prod` | https://elyx.life |

Required GitHub **environment variables** (per environment — prefixed so they don’t clash with other sites):

| Variable | Source (Terraform output) |
|----------|---------------------------|
| `ELYX_LIFE_2_AWS_ROLE_ARN` | `elyx_life_ci_role_arn` |
| `ELYX_LIFE_2_S3_BUCKET` | `elyx_life_frontend_bucket_name` |
| `ELYX_LIFE_2_CLOUDFRONT_DIST_ID` | `elyx_life_cloudfront_distribution_id` |

Set under **Settings → Environments → {staging\|prod} → Environment variables**.

```bash
# Example: staging (create the "staging" environment first if missing)
gh variable set ELYX_LIFE_2_AWS_ROLE_ARN --env staging --repo ElyxLife/elyx-website \
  --body "arn:aws:iam::791096174481:role/github-ci-elyx-life-staging"
gh variable set ELYX_LIFE_2_S3_BUCKET --env staging --repo ElyxLife/elyx-website \
  --body "elyx-life-staging-frontend"
gh variable set ELYX_LIFE_2_CLOUDFRONT_DIST_ID --env staging --repo ElyxLife/elyx-website \
  --body "E3KAS59MJ9788G"
```

Auth uses GitHub OIDC (no AWS access keys in GitHub). The role ARN is an identifier, not a secret.

## Production DNS (Namecheap)

DNS for `elyx.life` stays on **Namecheap**. AWS serves the site via CloudFront; you replace Squarespace records at cutover.

### 1. ACM certificate validation (two Terraform applies)

Prod uses external DNS (Namecheap), so infrastructure is applied in **two steps**:

**Step 1** — with `elyx_life_frontend_enable_cloudfront = false` in `elyx-infra/envs/prod/tfvars.auto.tfvars`:

```bash
cd elyx-infra/envs/prod
terraform apply
terraform output elyx_life_acm_domain_validation_options
```

In Namecheap → **elyx.life** → Advanced DNS, add each **CNAME** from the output. Wait until the ACM certificate status is **Issued** in the AWS console (usually 5–30 minutes).

**Step 2** — set `elyx_life_frontend_enable_cloudfront = true`, then apply again:

```bash
terraform apply
terraform output elyx_life_cloudfront_domain_name
```

This creates CloudFront and completes the GitHub deploy role (including cache invalidation permissions).

### 2. Point traffic at CloudFront

After cert is issued and a production deploy has content on S3:

1. Remove Squarespace records:
   - Apex **A** records (`198.49.23.*` / `198.185.159.*`)
   - **www** CNAME → `ext-cust.squarespace.com`
2. Add CloudFront (from `terraform output elyx_life_cloudfront_domain_name`):
   - **www:** CNAME → `dxxxx.cloudfront.net`
   - **@ (apex):** ALIAS/ANAME → same CloudFront domain (keeps URL as `elyx.life`)
3. Do **not** remove NS delegation records for subdomains (`360`, `auth`, `emr`, etc.)

### 3. Verify

```bash
dig +short elyx.life
dig +short www.elyx.life
curl -sI https://elyx.life
curl -sI https://www.elyx.life
```

### Formspree

Inquiry form posts to Formspree (`https://formspree.io/f/xnjkedyw`). Confirm the form is active in the Formspree dashboard and that notification email is set to the right inbox. Optionally set a Thank You redirect there as a fallback; the page also redirects to `/ThankYou.dc.html` via AJAX after a successful submit.

## Staging

`www.elyx.dev` is managed entirely in Route53 via Terraform — no Namecheap changes.
