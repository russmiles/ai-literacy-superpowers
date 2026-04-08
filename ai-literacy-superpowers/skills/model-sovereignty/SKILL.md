---
name: model-sovereignty
description: This skill should be used when the user asks about "local models", "custom models", "fine-tuning", "self-hosting models", "model selection", "which model should I use", "data privacy and models", "LoRA", "RAG vs fine-tuning", "Ollama", "vLLM", or wants guidance on whether to build, host, or customise their own AI models.
---

# Model Sovereignty

Model sovereignty is the practice of making deliberate decisions about
which models to use, where they run, and whether to create custom
models. It extends the framework's Theme #2 (Agency and Sovereignty)
into the model layer.

This skill guides practitioners through the decision framework from
cross-cutting Theme #17 and Appendix P of the framework.

## The Decision Hierarchy

Exhaust simpler approaches before escalating complexity. Each step
adds maintenance burden.

1. **Prompting + context engineering** — the default. Most teams
   underestimate how far this carries them. Exhaust it first.
2. **RAG** — when the limitation is knowledge (volatile, large, or
   frequently changing information).
3. **Fine-tuning (LoRA/QLoRA)** — when the limitation is behaviour
   (consistent domain-specific patterns at scale).
4. **Distillation** — when the limitation is size or speed (edge
   deployment, latency-sensitive applications).
5. **Local hosting** — when the limitation is privacy, cost at scale,
   or independence from vendor defaults.

## The Decision Framework

Walk through these questions in order. Stop at the first "yes."

**Does your data require local processing?**
PII, regulated data, trade secrets, or data subject to residency
requirements → local hosting is non-negotiable for those interactions.
Consult `references/decision-framework.md`.

**Does knowledge change frequently?**
Information changing weekly/monthly → add a RAG layer regardless of
hosting choice. RAG updates instantly; fine-tuning requires retraining.

**Does the model need consistent domain behaviour at scale?**
Reliable format compliance, style consistency, or decision logic across
thousands of requests → fine-tune with LoRA/QLoRA. Consult
`references/technique-comparison.md`.

**Is baseline load above the break-even threshold?**
~30M tokens/day sustained → self-hosted inference is economically
justified within 4 months. Consult `references/hosting-options.md`.

**None of the above?**
Use cloud API models with good prompting and context engineering.

## The Sovereignty Test

Ask: "If my API provider changed pricing, rate-limited me, or
discontinued my model tomorrow, what would happen?"

A sovereign engineer has an answer:

- A fallback model identified and tested
- Specifications precise enough to regenerate with any capable model
- Local alternatives evaluated for critical workflows
- Data classification that determines what can route where

## Getting Started

**For data sovereignty:** Start with data classification. List every
type of data that flows through your AI interactions. Classify each
as Public, Internal, Sensitive, or Restricted. Update MODEL_ROUTING.md
with routing rules based on classification.

**For cost sovereignty:** Calculate your monthly token usage. Compare
API costs against self-hosted alternatives at your volume. The
break-even is typically 30M tokens/day sustained.

**For domain sovereignty:** Identify your three most common AI failure
modes. If failures come from missing knowledge → evaluate RAG. If
failures come from inconsistent behaviour → evaluate fine-tuning. If
failures come from reasoning capability → stay on frontier APIs with
better prompting.

**For operational sovereignty:** Identify your vendor dependency. Could
you switch providers in a week? A month? Never? The answer determines
your urgency.

## Maintenance Awareness

Custom models accumulate maintenance debt. Budget for:

- Model versioning (pin versions, test before updating)
- Retraining cadence (quarterly for fine-tuned models)
- Drift detection (monitor output quality metrics)
- Exit strategy (every custom model should have a fallback)

For detailed technique comparisons, hosting option evaluation, and
current-era model recommendations, consult the reference files.
