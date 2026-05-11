---
layout: post
title: "Inferring Truth From Imperfect Evidence"
date: 2026-05-11
author: "Engineering Team"
category: "Platform"
excerpt: "Most people think wearable products are an integration problem. Connect Garmin, Oura, Apple Health, WHOOP, a CGM, and a smart scale, and you have a health platform."
---

<figure style="margin: 0 0 40px 0;">
  <img src="{{ '/assets/images/wearables-inferring-truth-hero.png' | relative_url }}" alt="Data from wearables flowing through ingestion and interpretation layers into curated storage and product surfaces." style="width: 100%; height: auto; border-radius: 8px;" />
</figure>

Most people think wearable products are an integration problem. Connect Garmin, Oura, Apple Health, WHOOP, a CGM, and a smart scale, and you have a health platform.

Spend enough time building these systems and you realize the integrations are the easy part. At least for the most common devices, tools like [https://tryterra.co/](https://tryterra.co/) and [https://www.junction.com/](https://www.junction.com/) make it easy. The hard part is interpretation.

Each source has its own schema, its own granularity, its own time model, and its own hidden assumptions.

One provider emits dense time series. Another emits daily summaries. One preserves provenance. Another collapses it. One records sleep as intervals, another as aggregates, another as a score. A workout may arrive directly from a watch, through Apple Health, and through an aggregator. A weight may come from a connected device or a manual entry. Glucose may be recorded in mmol/L or mg/dL. Timestamps may be local, UTC, shifted, delayed, or backfilled later.

A normal analytics pipeline can assume the source systems agree on what the data means. Wearables cannot. Even when two systems use the same label, they rarely mean the same thing.

AI compresses some of the execution and normalization work. But they are not good at deciding whether a sleep session that crosses midnight belongs to one day or another, whether two workouts from different sources are duplicates or distinct events, whether a glucose reading is aligned to the right local context, or whether one provider's "recovery" can be meaningfully compared to another's.

## The Interpretation layer

To build a good wearables system, we need to build the underlying system design and interpretation layer that decides what is canonical, what is duplicated, what is comparable, and what can be trusted and how much.

It has to infer truth from imperfect evidence. That shifts the engineering problem from "how do we move data?" to "how do we design a platform that can reason correctly about messy physiological signals?"

At a high level, the formula is:

- Ingest data from providers and apps.
- Preserve raw payloads.
- Normalize into internal models.
- Store curated data in BigQuery.
- Expose stable structures for dashboards, internal tools, and downstream services.
- Build monitoring around the data itself, not just the infrastructure.

None of this is exotic. The interesting part is deciding where meaning should live.

How much raw structure do you preserve?

How much normalization happens at ingestion time versus query time?

How do you support point measurements, interval events, and dense time series without turning the platform into a pile of special cases?

How do you preserve source context without making every downstream query unbearable?

How do you design a warehouse model that supports product features, operational checks, analytics, and AI on top of the same foundation?

For the interpretation to work correctly, wearables data has to be enriched with 3 non-negotiables - **Timezones**, **Canonicalization**, **Provenance**.

## Timezones

A sleep session crossing midnight, a late-arriving workout, a glucose spike after dinner, or a user moving across timezones can all produce a chart that is technically valid and semantically wrong at the same time.

You need a real model for UTC, local time, offsets, event intervals, late arrival, and user-day semantics. A platform that gets this wrong will still run. It will just quietly lose trust.

## Canonicalization

Garmin’s stress score estimates stress from heart rate variability and reports it on a 0–100 scale. WHOOP’s recovery score combines HRV, resting heart rate, sleep, respiratory rate, and other body signals into a daily readiness-style score. Oura’s readiness score also summarizes recovery, but using its own contributors such as sleep, activity, HRV, body temperature, and personal baselines. Apple Health HRV, meanwhile, is specifically SDNN: the standard deviation of normal-to-normal heartbeat intervals.

These signals may appear similar in a product experience, but they do not carry the same meaning.

Canonicalization prevents us from flattening them into generic metrics like “recovery” or “stress”. It defines the internal concepts our system is allowed to use: Garmin stress score, WHOOP recovery score, Oura readiness score, HRV SDNN, HRV RMSSD, sleep stage interval, sleep summary, daily steps, workout distance, and other clearly defined wearable concepts.

Canonicalization is the internal semantic contract for wearable data. It determines which provider-specific metrics stay provider-specific, which raw signals can be converted into common units, which metrics can be compared across devices, and which ones should only be interpreted within their original wearable ecosystem.

## Provenance

Where a record came from is part of what it means. A watch-recorded workout is not the same as one imported through a sync layer. A scale reading is not the same as a manual entry. A step count aggregated by one platform may hide a very different source chain than another.

So we preserve provenance aggressively: provider, app, device, ingestion path, source type, workout context, and anything else needed to reason about the record later. That is good for debugging. More importantly, it is good for truth.

## What a strong interpretation layer unlocks

AI is good at producing plausible language. It is not good at interpretation.

Models cannot tell on their own that two sources were improperly merged, that a timestamp was grouped into the wrong day, or that two similar-looking metrics should never have been compared. They lack the context to make those judgments, and that context does not arrive for free.

When the interpretation layer is weak, AI produces fluent nonsense.

When the layer is strong, the same model becomes genuinely useful. It can generate longitudinal narratives instead of one-off summaries. It can relate sleep, activity, recovery, nutrition, and glucose in the right temporal context. It can surface anomalies worth a human's attention. It can prioritize what matters instead of describing what happened.

## Who we are looking for

This is the kind of work where backend systems, product thinking, data modeling, observability, and AI architecture all meet.

You cannot solve it by being purely academic, because the inputs are too messy. You cannot solve it by being purely tactical, because the complexity compounds too quickly.

You have to build abstractions that are clean enough to scale and honest enough to survive reality.

At Elyx, we think the next generation of health software will not be defined by who collects the most data, but by who can make that data coherent enough for software, humans, and AI to use well.

We are looking for engineers who want to build that kind of foundation. If that sounds like you, get in touch.
