---
layout: post
title: "We Built an AI Pipeline That Writes Our UI Tests"
date: 2026-04-15
author: "Kshitiz Shankar"
excerpt: "In early April, our test-generation pipeline produced thirty Playwright tests for API endpoints that don't exist. Every test compiled. Every test would have hit the application with a 404 the first time CI touched it."
---

# We Built an AI Pipeline That Writes Our UI Tests

In early April, our test-generation pipeline produced thirty Playwright tests for API endpoints that don't exist. Every test compiled. Every test would have hit the application with a 404 the first time CI touched it. We caught it two weeks in.

This post is about how that happened, the five-agent pipeline that produced it, and why we now treat every intermediate output as something to verify rather than something to consume. We're a healthcare platform — timezone-aware clinical scheduling, role-based permissions for clinicians and members, wearable integrations, multi-step intake forms. The UI surface is wide enough that handwritten Playwright coverage was always going to lag the product. So we built something to write the tests for us.

We currently have 483 regression tests across 16 user journeys, generated from natural-language objectives. Several of them are red. They're red on purpose, and the reason is the most important thing in this post.

## Why "just generate tests" doesn't work

Ask an LLM to write a Playwright test for "schedule a clinical check-in" and you get something plausible. It imports the right libraries, navigates to a URL, clicks some buttons, asserts something.

It also uses selectors that match the wrong element. It assumes a popover auto-closes when it doesn't. It clicks a label when it should click a checkbox. It asserts against a stale response shape because it read the database schema instead of the actual API route.

UI testing needs three kinds of grounding in the same context: what the backend actually returns, what the DOM actually looks like at runtime, and what the conventions are for this specific codebase. No single prompt can carry all of that — which is the unsexy reason most "generate tests with AI" demos collapse the moment you take them off the demo path.

## Five specialized agents

We split the work into five stages — an orchestrator-workers decomposition in the sense Anthropic describes in [Building Effective Agents](https://www.anthropic.com/research/building-effective-agents). Focused jobs, focused context per agent, narrow handoffs.

**Enrichment.** Reads backend routes, validation schemas, and frontend components. Produces a document mapping the feature: which endpoints exist (with file citations), what fields are required/optional/nullable, what the component hierarchy looks like.

**Planning.** A different agent explores the running application in a browser. Clicks through the actual UI, observes what renders, notes which elements are interactive. Combines those observations with the enrichment doc to write a test plan: scenarios, edge cases, selector strategies.

**Generation.** Drives a headless browser to produce the actual test code. Has the plan, the enrichment doc, and a live app to interact with as it writes.

**Review.** Two agents in parallel. The convention reviewer checks for wrong selectors, missing accessibility patterns, hardcoded values. The coverage reviewer checks for untested parameters, missing error cases, unvalidated schema constraints.

**Healing.** When tests fail in CI, the healer reads the DOM snapshot, traces the selector to the component source, proposes a fix, and re-runs the test.

The Enricher doesn't need to know about selector conventions. The Generator doesn't need to read route files. Specialization means each agent can be smaller, more constrained, and more reliable — and the handoff between them becomes the place where most of the bugs live.

## The April incident

In early April, our Enricher started hallucinating API endpoints.

It read database table schemas — `panel_types`, `device_models`, `intervention_logs` — and inferred that corresponding REST routes must exist. It documented thirty endpoints like `POST /api/v1/panels` and `DELETE /api/v1/device-models/{id}` with confident descriptions, plausible request bodies, and accurate-looking response shapes. None of them were mounted in the application. The Generator dutifully wrote tests against all thirty, and they sat in the generated-but-unreviewed queue while we tuned other parts of the pipeline. When we finally got to them, every one returned 404\.

The root cause was two bugs at once.

Ours: the Enricher's prompt didn't require it to verify routes were actually mounted. Schema existence was enough for it to document a route. That one was on us.

The model's, separately: we were running on Claude Opus 4.6 through Claude Code, and in the weeks before our incident Anthropic had shipped three concurrent changes to the Claude Code / Agent SDK / Cowork surfaces. The relevant one for us turned out to be a [caching change deployed on March 26, 2026](https://www.anthropic.com/engineering/april-23-postmortem) that was meant to clear the model's older thinking only from idle sessions. A bug caused it to clear thinking *every turn* for the rest of the session. The effect, in Anthropic's own words, was that "Claude seem\[ed\] forgetful and repetitive." Independent telemetry from [Stella Laurenzo at AMD](https://github.com/anthropics/claude-code/issues/42796), published on April 2, measured a 67% drop in median reasoning depth across 6,852 Claude Code sessions in this window.

The fit was exact. An Enricher in the middle of a multi-turn route investigation needs to carry observations forward — "I opened `routes.py` and saw these route handlers; now let me check the corresponding controllers" — to ground later claims in actual file evidence. When the model's own prior thinking gets wiped between turns, it falls back on whatever the prompt and the immediate context can produce. For a route-discovery task, that fallback is *infer from the schemas* — which is exactly the speculative behavior we observed. The bug was fixed on April 10\.

Either bug alone would have been recoverable. Together they produced thirty phantom tests we wrote, queued, and almost ran in CI.

We caught it only when the generated files hit the reviewer queue. We should have caught it the moment Enricher accuracy dropped — but we had no Enricher accuracy metric. We were grading the pipeline on its final output (passing tests) instead of its intermediate outputs (are the enrichment docs accurate?).

The lesson is unflattering but useful. *The version of the model you built against in February is not the version you're running in April, even if the model name and the API endpoint haven't changed.* Pipeline quality is coupled to upstream changes you don't control and can't predict. Anthropic's postmortem is more detail than most vendors produce; it also landed three weeks after the first widely-shared evidence on GitHub, after the operational consequences for downstream teams had already accrued. The depth of the postmortem is the kind of thing that should encourage other vendors. The lag is the reason teams running on top of these models need their own evals at every handoff.

We fixed our Enricher prompt the same day we identified the cause: *"if you cannot find the route file in the application, do not document the endpoint."* The eval infrastructure to detect this class of regression earlier is still future work. We have an opinion about how to build it, which is the closing section of this post.

## The biggest improvement: a codebase knowledge graph

Before the change, each agent searched the codebase independently. Grep for routes here, file reads there. The Enricher might find six of the eight relevant files. The coverage reviewer might find a different six. Neither would see cross-layer connections — this frontend component calls this API route which queries this database view which joins three tables, including the one that tracks longitudinal member sessions.

After the change, we pre-compute a knowledge graph of the entire codebase. Files as nodes, imports and calls and references as edges, clustered into communities. Before any agent runs, a script queries the graph for the feature area and produces a structured brief: key files, data flows, most-connected components, untested paths.

Every agent downstream gets the same map. They aren't inferring codebase structure from partial grep results; they're reading a pre-computed answer to "what's involved in this feature?"

The hallucination rate dropped immediately. Not because the agents got smarter, but because they had less room to speculate.

We've started applying the same pattern outside the test pipeline. Any system where multiple agents need codebase context benefits more from structured pre-computation than from giving each agent better search tools. The search tools are fine. The problem is that independent search produces independent and slightly-different mental models of the code, and downstream agents have no way to reconcile the differences.

Pre-computed briefs also help when the model itself fails. When Claude lost its ability to carry context across turns in April, the brief loaded into every agent's opening context was the part still grounded in real files. The reasoning could degrade; the brief could not.

## Why some of our tests are red on purpose

Some of our generated tests are red. We don't delete them.

test.fixme(

  'reminders for time-zone-changed members fire in UTC, not local time',

  async ({ page }) \=\> {

    // The Planning agent caught this exploring the appointments flow.

    // When a member updates their timezone within \~1 hour of an existing

    // appointment, the reminder job picks up the old TZ.

    // Filed as BUG-2147. Reproduces reliably.

    // Keeping the test so the regression is visible the day we ship a fix.

  }

);

A `fixme` test is documentation of a known bug. Ugly in the test report, honest about what it represents. Several of our `fixme` tests turned out to be real application bugs nobody had caught through manual testing — the Planning phase explores the UI by trying combinations a human tester wouldn't have prioritized (a member changing timezone within an hour of an appointment, or a clinician with two active roles attempting an action permitted by one and forbidden by the other).

In a healthcare product, the difference between an acknowledged gap and a hidden one matters more than it does in most products. A late reminder for a routine check-in is annoying; the same delivery mechanism is shared with medication-adherence prompts and clinician escalations. A test report that names what's broken is worth more than one that hides it. The pressure to make CI green is real, and we resist it deliberately.

## What we'd do differently

**Verify every intermediate output, not just the final one.** The April incident happened because we graded the pipeline on passing tests instead of agent accuracy. A pipeline where one agent's output feeds another has to verify at each handoff. Plausible-looking output is the dangerous kind — it survives long enough to do damage.

**Invest in the Healer earlier.** The Generator has roughly a 70% first-pass rate on simple scenarios and drops to maybe 10% on complex UI interactions — virtualized lists, multi-step intake wizards, conditional rendering driven by clinical state (e.g. a form that branches on whether the member has an active medication flag). The Healer fixes most of those now, but we underinvested in it early and spent too much human time manually fixing selector issues the Healer could have caught.

**Serialize carefully.** Running multiple browser-driving agents in parallel crashes things. Running tests while agents are active causes out-of-memory failures. Agent pipelines are resource-intensive in ways that aren't obvious until your CI machine runs out of RAM at 2am.

## Where this is going

The pipeline works. 483 tests, 16 journeys, real bugs surfaced, shared helpers that make future tests cheaper to write. The honest version of where we are: we're building this the way most teams build ML systems in year one — it works, we can't fully explain why, and we're nervous about what happens when the infrastructure shifts beneath us. The April incident is the reason we're nervous. It is also the reason this is the right problem to invest in next.

The next problem is evals. Right now we can count passing tests but we cannot answer: what percentage of documented endpoints actually exist? What's the Generator's first-pass success rate broken down by scenario type? How many Reviewer suggestions are false positives that the team has learned to ignore? Without those numbers, we tune by feel. We caught the April regression two weeks late. Next time it could be a month.

In healthcare, the test suite is part of the compliance story, not separate from it. We can't keep tuning by feel when the system we're testing makes decisions that touch members' care. Making the pipeline measurable — Enricher accuracy, Generator first-pass conversion, Reviewer precision, Healer recovery rate, all as first-class numbers we publish internally — is the next thing we ship.

---
