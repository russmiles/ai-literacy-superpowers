---
title: model-cards
layout: default
parent: Plugins
nav_order: 1
has_children: true
---

# model-cards

Research and author Mitchell-extended model cards from a model name.

`model-cards` is a sister plugin to `ai-literacy-superpowers` in the same
marketplace. It is aimed at evaluators researching new models, and
produces 10-section cards (Mitchell et al.'s 9 canonical sections plus
an "Operational Details" section for consumer-evaluator audiences) with
per-claim citations and tiered source provenance.

The plugin's source lives at [`model-cards/`](https://github.com/Habitat-Thinking/ai-literacy-superpowers/tree/main/model-cards)
in the repository.

---

## Install

```bash
# In Claude Code
claude plugin install model-cards@ai-literacy-superpowers

# In Copilot CLI
copilot plugin install model-cards@ai-literacy-superpowers
```

The marketplace `ai-literacy-superpowers` must be added first; see the
top-level [Get Started]({% link plugins/ai-literacy-superpowers/getting-started.md %}) tutorial
for the install flow.

---

## Quick start

```text
/model-card create claude-opus-4-7
```

Researches the model through a tiered source strategy (provider docs →
HuggingFace → arXiv → web), shows a review summary, and writes the card
to your library on accept. See the
[research a model card]({% link plugins/model-cards/research-a-model-card.md %})
how-to for the full flow.

To populate the library with cards for a shipped list of 14 frontier
models in one shot:

```text
/model-card seed
```

See [seed your library]({% link plugins/model-cards/seed-your-library.md %}).

---

## Documentation

### Tutorials — start here

- [Seed your model card library]({% link plugins/model-cards/seed-your-library.md %}) —
  walk through `/model-card seed` end-to-end and inspect the resulting library.

### How-to guides — task-oriented

- [Research a model card]({% link plugins/model-cards/research-a-model-card.md %}) —
  produce a card for a single model with `/model-card create`.

### Reference — exact details

- [Commands]({% link plugins/model-cards/commands.md %}) — `/model-card`
  and its subcommands, flags, and exit behaviours.
- [Agent: model-card-researcher]({% link plugins/model-cards/agents.md %}) —
  the read-only research agent's charter, tools, and refusal behaviour.
- [Skill: model-cards]({% link plugins/model-cards/skills.md %}) —
  authoring reference for the 10-section card structure.
- [Card template]({% link plugins/model-cards/card-template.md %}) —
  the `MODEL_CARD.md` template each card is generated against.

### Explanation — concepts

- [Mitchell-extended model cards]({% link plugins/model-cards/mitchell-extended-cards.md %}) —
  why the cards have ten sections, what the citation tiers buy you,
  and how the existence-check refusal pattern prevents authoritative-
  looking cards for hallucinated models.

---

## Honesty rules at a glance

- **"Not publicly available"** is the canonical answer when a tier-1
  source is silent and lower tiers cannot confirm. The agent never
  fabricates.
- **Existence check** — if tier-1 (provider docs) **and** tier-2
  (HuggingFace) are both silent on the model itself, the agent
  refuses to produce a card and surfaces the refusal to the user. No
  file is written.
- **Source-tier conflict resolution** — when a tier-4 (web) claim
  conflicts with a tier-1 (provider docs) claim, tier-1 wins; the
  conflict is recorded in the card's Caveats section.

These rules are documented in detail in the
[Mitchell-extended model cards]({% link plugins/model-cards/mitchell-extended-cards.md %})
explanation page.
