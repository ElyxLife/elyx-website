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
  support.js          # DC runtime (generated bundle)
  image-slot.js
  assets/             # Local images
  robots.txt
  sitemap.xml
```

## Deploy

Deployments are **manual** via GitHub Actions (no push trigger):

| Workflow | Environment | URL |
|----------|-------------|-----|
| Deploy Elyx Life 2 (Staging) | `staging` | https://www.elyx.dev |
| Deploy Elyx Life 2 (Production) | `prod` | https://elyx.life |

Required GitHub **environment variables** (per environment — not secrets; these are deploy targets, not credentials):

| Variable | Staging value (after Terraform apply) |
|----------|---------------------------------------|
| `AWS_ROLE_ARN` | `terraform output -raw elyx_life_ci_role_arn` |
| `S3_BUCKET` | `terraform output -raw elyx_life_frontend_bucket_name` |
| `CLOUDFRONT_DIST_ID` | `terraform output -raw elyx_life_cloudfront_distribution_id` |

Set under **Settings → Environments → {staging\|prod} → Environment variables**.

```bash
# Example: staging (create the "staging" environment first if missing)
gh variable set AWS_ROLE_ARN --env staging --repo ElyxLife/elyx-website \
  --body "arn:aws:iam::791096174481:role/github-ci-elyx-life-staging"
gh variable set S3_BUCKET --env staging --repo ElyxLife/elyx-website \
  --body "elyx-life-staging-frontend"
gh variable set CLOUDFRONT_DIST_ID --env staging --repo ElyxLife/elyx-website \
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

### FormSubmit

First live Inquiry submission emails `business@elyx.life` a one-time FormSubmit activation link.

## Staging

`www.elyx.dev` is managed entirely in Route53 via Terraform — no Namecheap changes.
