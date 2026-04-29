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

[Get Started](plugins/ai-literacy-superpowers/getting-started){: .btn .btn-primary .fs-5 .mb-4 .mb-md-0 .mr-2 }
[Install Now](#quick-install){: .btn .fs-5 .mb-4 .mb-md-0 }

---

## Quick Install

**Claude Code:**

```bash
claude plugin marketplace add Habitat-Thinking/ai-literacy-superpowers
claude plugin install ai-literacy-superpowers
```

**GitHub Copilot CLI:**

```bash
copilot plugin marketplace add Habitat-Thinking/ai-literacy-superpowers
copilot plugin install ai-literacy-superpowers@ai-literacy-superpowers
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

- **30 skills** — domain knowledge for security auditing, constraint
  design, context engineering, fitness functions, model sovereignty,
  decision archaeology, and more
- **13 agents** — autonomous workers for orchestration, enforcement,
  garbage collection, code review, governance auditing, adversarial
  spec/code review, decision archaeology, and TDD
- **24 commands** — slash commands for harness lifecycle, assessment,
  portfolio assessment, reflection, governance, onboarding, affordance
  inventory, decision-archaeology mapping, and convention management
- **3 enforcement loops** — advisory at edit time, strict at merge
  time, investigative on schedule

## Documentation Structure

Documentation is organised **per plugin**. Each plugin in the
marketplace has its own landing page with tutorials, how-to guides,
reference material, and explanation pages, organised using the
[Diataxis framework](https://diataxis.fr/).

| Plugin | What it does |
| ------ | ------------ |
| [ai-literacy-superpowers]({% link plugins/ai-literacy-superpowers/index.md %}) | Harness engineering, agent orchestration, literate programming, CUPID code review, compound learning. The flagship plugin. |
| [model-cards]({% link plugins/model-cards/index.md %}) | Researches and authors Mitchell-extended model cards from a model name. |

See the [Plugins index]({% link plugins/index.md %}) for the full
listing.

### Old URLs

The previous flat layout (`/tutorials/`, `/how-to/`, `/reference/`,
`/explanation/`) was reorganised on 2026-04-29 to support multiple
plugins in the same marketplace. Old URLs redirect to the new
plugin-scoped paths automatically.
