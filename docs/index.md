---
title: Home
layout: default
nav_order: 1
---

# ai-literacy-superpowers

A Claude Code plugin that brings harness engineering to your development
workflow — deterministic constraints, agent-based review, garbage
collection, and a self-improving learning loop that gets better every
session.

{: .fs-6 .fw-300 }

[Get Started](tutorials/getting-started){: .btn .btn-primary .fs-5 .mb-4 .mb-md-0 .mr-2 }
[Install Now](#quick-install){: .btn .fs-5 .mb-4 .mb-md-0 }

---

## Quick Install

```bash
claude plugin marketplace add Habitat-Thinking/ai-literacy-superpowers
claude plugin install ai-literacy-superpowers
```

Then in any project:

```bash
/harness-init    # Set up a living harness (choose which features to configure)
/harness-status  # Check enforcement health
```

`/harness-init` lets you select which features to configure — context
engineering, constraints, garbage collection, CI, and observability. All
are selected by default. Re-run at any time to add more; existing
configuration is preserved.

## What This Plugin Does

The plugin implements **harness engineering** — the practice of
surrounding AI code generation with deterministic tooling, agent-based
review, and periodic entropy checks so that AI-assisted development
stays trustworthy at scale.

It gives you:

- **20 skills** — domain knowledge for security auditing, constraint
  design, context engineering, fitness functions, model sovereignty, and more
- **10 agents** — autonomous workers for orchestration, enforcement,
  garbage collection, code review, and TDD
- **13 commands** — slash commands for harness lifecycle, assessment,
  reflection, and convention management
- **3 enforcement loops** — advisory at edit time, strict at merge
  time, investigative on schedule

## Documentation Structure

This documentation follows the [Diataxis framework](https://diataxis.fr/):

| Section | Purpose | Start here if... |
| ------- | ------- | ----------------- |
| [Tutorials](tutorials/) | Learning-oriented walkthroughs | You're new to the plugin |
| [How-to Guides](how-to/) | Task-oriented instructions | You need to do something specific |
| [Reference](reference/) | Technical descriptions | You need exact details |
| [Explanation](explanation/) | Understanding-oriented discussion | You want to understand the concepts |
