---
layout: post
title: "Product Development in an AI-First Organization"
date: 2025-03-26
image: /assets/images/blog/Gemini_Generated_Image_undm3uundm3uundm.png
---

*The modern engineer doesn't just build the solution; they build the system that discovers the solution.*

Most people think software engineering is about writing code. If you spend enough time doing it, you realize it's actually about translation. The world is a mess of vague desires and half-formed ideas. A computer, by contrast, is a machine that demands absolute precision. The job of the engineer is to take the mess and turn it into a specification.

Historically, this was expensive. To build even a simple form, you had to worry about a dozen things the user never mentioned: handling race conditions if they double-clicked 'submit,' sanitizing inputs to prevent a database breach, or managing the UI state when a network request timed out halfway through. We built abstractions—frameworks and libraries—to handle the "defaults." But fitting those abstractions to a specific problem still required a high degree of technical labor. You had to know which gaps to fill and which tradeoffs to accept.

LLMs have changed the nature of that labor. An LLM is, essentially, a machine for making reasonable assumptions. It can look at a vague requirement and fill in the technical gaps that used to take an afternoon to code. It can even write the specification itself.

This leads to an obvious question: If the AI can write the code and the spec, what is left for the human?

The conventional answer is "context." An LLM knows everything in general, but nothing about your problem in particular. It can guess, but its guesses are only as good as the constraints you provide. The "hard part" of engineering hasn't disappeared; it has moved upstream. The discipline required to craft a technical solution is now the discipline required to identify and extract the unique constraints of a business problem.

This shift is collapsing the traditional distinction between the Product Manager and the Software Engineer. In the old world, the PM handled the "what" (user stories, flow, discovery) and the engineer handled the "how" (infra, backend, implementation).

When AI handles the bulk of the "how," the "what" becomes the bottleneck. It is now feasible for a single person—a Product Engineer—to orchestrate the entire stack. They don't just implement a spec; they talk to users, create a process to capture the needs into product specifications, define the system's guardrails, and feed the right context into the AI to realize the solution.

But we can go one step further. If the "what" is the new bottleneck, we can treat the discovery process itself as an engineering problem. By encoding a specific product philosophy into the AI—a set of heuristics for what makes a feature "good" or a system resilient—the machine stops being a passive builder and becomes an active interlocutor.

For example, instead of just accepting a request for a new dashboard, an AI with the right "product brain" might cross-reference the request against the existing database schema and ask the user: *"I understand you want to see the fat % on this dashboard. Are there other types of clients where you want to see a different metrics? What are the different client types, and can you give examples of metrics you would want to see in each type?"* Or it might identify a logical conflict, pointing out that a new privacy feature actually breaks a previously requested collaboration tool. At that point, the AI isn't just filling in the gaps of a spec; it is helping the user discover what the spec should be in the first place.

At Elyx, every engineer is a product engineer. We don't just build systems; we build the frameworks that allow AI to understand our users. We work on every part of the stack because, in this new world, the stack is a single, continuous loop from user intent to working code.

We are looking for engineers who care more about building the right product than just writing more code. If that sounds like you, [get in touch](/join-us).
