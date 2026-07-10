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

Required GitHub environment secrets (per environment):

- `AWS_ROLE_ARN`
- `S3_BUCKET`
- `CLOUDFRONT_DIST_ID`

Values come from `elyx-infra` Terraform outputs after apply.

## Production DNS (Namecheap)

DNS for `elyx.life` stays on **Namecheap**. AWS serves the site via CloudFront; you replace Squarespace records at cutover.

### 1. ACM certificate validation

After prod Terraform apply starts, get validation records:

```bash
cd elyx-infra/envs/prod
terraform output elyx_life_acm_domain_validation_options
```

In Namecheap → **elyx.life** → Advanced DNS, add each **CNAME** (name + value from output). Wait until ACM status is **Issued** (Terraform apply may pause until this completes).

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
