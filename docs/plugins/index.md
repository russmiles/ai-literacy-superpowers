---
title: Plugins
layout: default
nav_order: 6
has_children: true
---

# Plugins

The `ai-literacy-superpowers` marketplace ships more than one plugin.
This section documents each plugin individually, with its own tutorials,
how-to guides, reference material, and explanation pages.

The top-level [Tutorials]({% link tutorials/index.md %}),
[How-to Guides]({% link how-to/index.md %}),
[Reference]({% link reference/index.md %}), and
[Explanation]({% link explanation/index.md %}) sections currently
document `ai-literacy-superpowers` only and will be migrated under this
Plugins section in a follow-up. New sister plugins go straight into the
Plugins section.

## Available plugins

| Plugin | What it does | Docs |
| ------ | ------------ | ---- |
| [model-cards]({% link plugins/model-cards/index.md %}) | Researches and authors Mitchell-extended model cards from a model name. Tiered source strategy, refusal-on-unconfirmed-existence honesty rule. | [→ model-cards docs]({% link plugins/model-cards/index.md %}) |

## Why per-plugin documentation

Each plugin in the marketplace has its own commands, agents, skills,
templates, and operational shape. Mixing them into one global reference
makes it harder to discover what belongs to which plugin and harder for
each plugin to evolve at its own pace. Per-plugin sub-sections keep
each plugin's documentation cohesive while still letting cross-cutting
concepts live in shared explanation pages.
