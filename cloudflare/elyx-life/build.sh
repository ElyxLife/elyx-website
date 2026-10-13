#!/usr/bin/env bash
# Build the static site the same way production publishes it to S3:
# copy the site, then place each page at its clean URL.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
SRC="$(cd "$HERE/../../elyx-life-2" && pwd)"
DIST="$HERE/dist"

rm -rf "$DIST"
mkdir -p "$DIST"

rsync -a \
  --exclude '.DS_Store' \
  --exclude 'README.md' \
  --exclude 'robots.staging.txt' \
  --exclude '* 2.html' \
  --exclude 'how-we-work' \
  --exclude 'the-team' \
  --exclude 'perspectives' \
  --exclude 'membership' \
  --exclude 'health-maximization-system' \
  --exclude 'science-for-the-life-you-want' \
  --exclude 'the-science' \
  --exclude 'research' \
  --exclude 'media-center' \
  --exclude 'location' \
  --exclude 'enquire' \
  --exclude 'careers' \
  --exclude 'thank-you' \
  --exclude 'journal' \
  --exclude 'support' \
  --exclude 'privacy' \
  --exclude 'pengtong' \
  "$SRC/" "$DIST/"

publish() {
  local src="$1"
  local dest="$2"
  mkdir -p "$DIST/$dest"
  cp "$SRC/$src" "$DIST/$dest/index.html"
}

publish Intelligence.dc.html how-we-work
publish WhoWeAre.dc.html the-team
publish Perspectives.dc.html perspectives
publish Membership.dc.html membership
publish HealthMaximizationSystem.dc.html the-science
publish ScienceForLifeWhitePaper.dc.html science-for-the-life-you-want
publish HealthMaximizationSystemRedirect.dc.html research/science-for-the-life-you-want
publish HealthMaximizationSystemRedirect.dc.html health-maximization-system
publish MediaCenter.dc.html media-center
publish Location.dc.html location
publish Inquiry.dc.html enquire
publish Careers.dc.html careers
publish Job-HeadOfEngineering.dc.html careers/head-of-engineering
publish Job-FullStackEngineer.dc.html careers/full-stack-engineer
publish Job-HealthspanProductManager.dc.html careers/healthspan-product-manager
publish ThankYou.dc.html thank-you
publish Journal-Price-of-Staying-Capable.dc.html journal/the-price-of-staying-capable
publish Journal-Signal-and-Noise.dc.html journal/signal-and-noise
publish Journal-L-Theanine.dc.html journal/l-theanine
publish Journal-Index.dc.html journal
publish Journal-Stop-Romanticizing-Death.dc.html journal/stop-romanticizing-death
publish Support.dc.html support
publish Privacy.dc.html privacy
publish Pengtong.dc.html pengtong

echo "Built $DIST"
