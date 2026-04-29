# Spec: model-cards plugin (v0.1.0)

**Date**: 2026-04-29
**Author**: Russ Miles + assistant (via brainstorming skill)
**Driving signal**: User curiosity (evaluating models for own use) + marketplace gap (no model-card plugin in the Claude Code marketplace) + sister-plugin opportunity for the existing `Habitat-Thinking/ai-literacy-superpowers` marketplace repo
**Status**: design — awaiting spec-mode `/diaboli` and user review

## Problem

The `ai-literacy-superpowers` marketplace currently hosts one plugin —
`ai-literacy-superpowers` — focused on AI literacy for software
engineering teams *using* commercial LLMs. A complementary need is
**evaluating** models: when a new frontier model ships, what does it
do, what are its limitations, what does it cost, what data can route
to it? The 2026-04-29 exploration of "should we add model cards to
the existing plugin?" concluded Option F (no-op) on audience-asymmetry
grounds — but a *separate* plugin targeting evaluators directly does
not have that asymmetry problem.

This spec designs the second plugin in the marketplace:
**`model-cards`** — a research-and-authoring plugin that, given a
model name, autonomously researches the model and produces a
Mitchell et al. (2019) style card extended with operational details
relevant to consumers (pricing, context window, knowledge cutoff,
SDK support).

## Goals

1. **Single-command research-and-author flow** — user types
   `/model-card create <name>`, plugin researches the model and
   produces a draft card.
2. **Tiered source strategy** — provider docs first, HuggingFace
   second, arXiv third, web search as fallback. Cheap sources before
   expensive ones; explicit per-claim citation.
3. **Hybrid review-before-commit** — agent presents a draft summary;
   user accepts / edits / re-runs sections / aborts before the card
   lands in the library.
4. **Per-user library by default** — cards live at
   `~/.claude/model-cards/<provider>/<model-name>.md` so they survive
   across projects (configurable via env var or flag).
5. **Seed subcommand** — `/model-card seed` populates the library
   with a shipped frontier-LLM list on demand.
6. **Honest about limits** — "Not publicly available" rather than
   fabrication for proprietary opacity. Source provenance per claim.

## Non-goals (this v0.1.0)

- **Comparison of cards** — `/model-card compare` is captured as a
  future subcommand and a tracking issue. Not implemented in v0.1.0.
- **Refresh on new releases** — `/model-card refresh` is a future
  subcommand; tracking issue. Not in v0.1.0.
- **Library browsing UX** — beyond `cards/<provider>/<model-name>.md`
  folder convention, no list / index / browse surface. Future.
- **Schema cleanup of marketplace.json `plugin_version` field** —
  separate concern; tracking issue created. This PR uses Option A
  (keep field, point at canonical plugin).
- **Sharing / publishing cards externally** — out of scope.
- **Continuous monitoring** — out of scope.

## Decisions

The design space was explored through six clarifying questions during
brainstorming. The decisions:

| # | Decision axis | Choice | Rationale |
| --- | --- | --- | --- |
| Q1 | Model scope | **Any named model**, with shipped default = frontier LLMs from major providers (concrete seed list) | Matches stated use case (curiosity-driven evaluation); seed list gives instant library on first install |
| Q2 | Research sources | **Tiered: provider docs → HuggingFace → arXiv → web search** | Cheap sources before expensive ones; per-section primary-source mapping; explicit provenance |
| Q3 | Card format | **Mitchell-extended**: 9 canonical sections + 10th "Operational Details" section | Industry-recognised + fills the consumer-evaluator gap; one template, "Not publicly available" for proprietary opacity |
| Q4 | Invocation pattern | **Hybrid: command + autonomous research + review-before-commit** | AI-researched content is hallucination-prone; review checkpoint before library entry is load-bearing for trustworthy cards |
| Q5 | Storage location | **Configurable, default `~/.claude/model-cards/<provider>/<model-name>.md`** | Per-user (not per-project) matches stated use case; configurable via `--out` flag and `MODEL_CARDS_DIR` env var |
| Q5b | Seed command | **Ship `/model-card seed`** with bundled `frontier-models.json` list (14 models) | "Shipped default" interpretation; instant library on install; users can extend the JSON list |
| Q6a | Plugin name | **`model-cards`** | Short, descriptive; `-superpowers` suffix reads as "another big plugin" but this one is intentionally small |
| Q6b | Command shape | **`/model-card <subcommand>`** (subcommand pattern, mirrors `/worktree spin/merge/clean`) | Plugin focused around one noun; subcommands cleaner than 3-5 top-level slash commands |
| Schema | `plugin_version` field handling | **Option A — keep, point at canonical `ai-literacy-superpowers`** | Backward-compatible for v0.1.0; cleanup deferred to a separate tracking issue per yesterday's lesson on not riding convention changes in on feature PRs |

## Architecture

A second plugin at the repo root, mirroring `ai-literacy-superpowers/`'s
layout convention.

```text
model-cards/
├── .claude-plugin/
│   └── plugin.json                              ← name "model-cards", v0.1.0
├── agents/
│   └── model-card-researcher.agent.md           ← the research agent
├── commands/
│   └── model-card.md                            ← /model-card create|seed
├── skills/
│   └── model-cards/
│       └── SKILL.md                             ← Mitchell-extended framework guidance
├── templates/
│   └── MODEL_CARD.md                            ← the 10-section template
├── seed/
│   └── frontier-models.json                     ← JSON list of frontier LLMs
├── CHANGELOG.md                                 ← starts at v0.1.0
└── README.md                                    ← plugin landing page
```

**No hooks, no scripts/, no harness for v0.1.0.** YAGNI applies. Can
be added when there's load-bearing need.

### Component responsibilities

| Component | Responsibility | Reads | Writes |
| --- | --- | --- | --- |
| `plugin.json` | Plugin manifest | — | — |
| `model-card-researcher.agent.md` | Charter for research agent: tiered sources, per-section research, citation discipline, honest "Not publicly available" for opacity | input from dispatcher | output content (markdown string) returned to dispatcher |
| `model-card.md` (command) | Subcommand dispatcher: parses args, routes to create/seed flow, runs hybrid review, writes file | agent output, seed JSON | card files in library, stdout |
| `MODEL_CARD.md` (template) | The 10-section structure with frontmatter shape and citation format | — | — |
| `model-cards/SKILL.md` | Mitchell-extended framework guidance: when each section applies, citation discipline, honesty rules | — | — |
| `frontier-models.json` | Seed list for `/model-card seed` | — | — |

## Card template

`templates/MODEL_CARD.md` — frontmatter + 10 sections, with per-claim
citation footnotes resolving via the frontmatter `sources` block.

```markdown
---
model_name: <provider>/<model-name>
provider: <Anthropic | OpenAI | Google | …>
model_version: <as-stated-by-provider>
last_researched: YYYY-MM-DD
card_version: 0.1.0
researcher: model-card-researcher (claude-opus-4-7[1m])
sources:
  - tier: 1
    url: <provider docs URL>
    fetched: YYYY-MM-DD
  - tier: 2
    url: <huggingface URL>
    fetched: YYYY-MM-DD
  - tier: 3
    url: <arxiv URL>
    fetched: YYYY-MM-DD
  - tier: 4
    url: <web URL>
    fetched: YYYY-MM-DD
---

# Model Card: <provider>/<model-name>

## 1. Model Details
What this model is, who released it, when, what kind of model.

## 2. Intended Use
Primary uses, primary users, out-of-scope uses (per the provider).

## 3. Factors
Relevant subgroups, environmental factors, instrumentation factors.

## 4. Metrics
Performance measures the provider reports.

## 5. Evaluation Data
Datasets used to evaluate (per the provider's published statements).

## 6. Training Data
Datasets used to train (per the provider's published statements).

## 7. Quantitative Analyses
Disaggregated performance — when provider has published this.

## 8. Ethical Considerations
Risks, mitigations, known failure modes.

## 9. Caveats and Recommendations
What this card cannot tell you. Recommendations for use.

## 10. Operational Details
Pricing (input/output per million tokens), context window, knowledge
cutoff, supported APIs/SDKs, latency tier, tool/structured-output
support, function calling, fine-tuning availability, rate limit notes.
```

### Citation scheme

Per-claim footnote-style: `[T<n>.<m>]` where `n` is the tier (1-4)
and `m` is the source index within that tier.

Example:

```markdown
Knowledge cutoff: January 2026 [T1.1]. Context window: 1M tokens
[T1.2]. Pricing: $5/$25 per million tokens (input/output) at standard
tier [T1.3].
```

`T1.1`, `T1.2`, `T1.3` resolve via the frontmatter `sources` list.

### Honesty rules (in agent charter)

- "Not publicly available" is the canonical answer when tier-1 is
  silent and lower tiers cannot confirm. Never fabricate.
- "Per the provider's published statements" framing is preferred
  over assertion — preserves the source-trust chain.
- If a tier-4 web claim conflicts with a tier-1 provider claim,
  tier-1 wins; the conflict is flagged in Section 9 (Caveats).

## Research agent

`agents/model-card-researcher.agent.md`.

**Charter** (system prompt):

> You are the model-card-researcher. Given a model name (and optional
> provider hint), you produce a Mitchell-extended model card by
> researching the model through a tiered source strategy. You cite
> every factual claim. You write "Not publicly available" rather
> than fabricate.

**Tools**: `WebFetch`, `WebSearch`, `Read`, `Write`, `Glob`, `Grep`.
No `Edit`, no `Bash` — research and authoring only.

**Tiered source strategy**:

| Tier | Source | Discovery |
| --- | --- | --- |
| 1 | Provider docs | URL inferred from a provider→docs-root mapping shipped in agent context |
| 2 | HuggingFace card | `huggingface.co/<owner>/<model>` if model is on HF |
| 3 | arXiv release paper | Discovered via `WebSearch` for `"<model-name>" arxiv` |
| 4 | Web search | `WebSearch` with explicit query, prefer recent results |

**Per-section primary source mapping**:

| Section | Primary source | Fallback |
| --- | --- | --- |
| Model Details | Tier 1 | Tier 2 → 4 |
| Intended Use | Tier 1 | Tier 2 → 4 |
| Factors | Tier 3 (paper) | Tier 1, then 2 |
| Metrics | Tier 1 + Tier 3 | — |
| Evaluation Data | Tier 3 | Tier 1 |
| Training Data | Tier 3 | Tier 1 (often "Not publicly available") |
| Quantitative Analyses | Tier 3 | Tier 1 |
| Ethical Considerations | Tier 3 + Tier 1 | Tier 4 |
| Caveats and Recommendations | Synthesised | — |
| Operational Details | Tier 1 | Tier 4 (especially pricing) |

**Output**: a single markdown string (full card content). The
dispatching command writes the file. This separation mirrors
`advocatus-diaboli`'s pattern.

## Commands

`commands/model-card.md` — single command with subcommand dispatch.

### `/model-card create <model-name> [--provider X] [--out path]`

Hybrid flow:

```text
1. Parse args
2. Resolve target path (default ~/.claude/model-cards/<provider>/<model-name>.md;
   apply MODEL_CARDS_DIR env var if set; apply --out flag if passed)
3. Check for existing card at target path
   If present: warn user, ask "overwrite / skip / load-existing-as-base"
4. Dispatch model-card-researcher agent
5. Show review summary
   - Sources used per section (tier breakdown)
   - Sections that came up thin ("Not publicly available" count)
   - Top 3 most-cited claims with their sources
   - Estimated token cost of the research
6. Ask: accept / edit / re-run-section <N> / abort
   - accept: write to target path
   - edit: open in $EDITOR, then re-prompt accept
   - re-run-section <N>: re-dispatch agent with section-specific prompt
   - abort: discard draft, no file written
7. On accept: write file, print confirmation with full path
```

### `/model-card seed`

Non-interactive bulk research over the shipped frontier list:

```text
1. Read seed list from ${CLAUDE_PLUGIN_ROOT}/seed/frontier-models.json
2. Show user the list and total count
3. Ask once: "Research N cards into <library-path>? [y/N]"
4. For each model in list:
   a. Skip if card exists at target path (unless --force flag)
   b. Dispatch model-card-researcher
   c. Write result without per-card review
   d. Print one-line progress
5. Print summary: created, skipped, failed
```

### Future subcommands (out of v0.1.0 scope)

Tracking issues created post-spec-commit:

- `/model-card list` — browse the library
- `/model-card compare <a> <b>` — side-by-side comparison
- `/model-card refresh <name>` — re-research a specific card

### Initial seed list

`seed/frontier-models.json` for v0.1.0:

```json
[
  {"name": "claude-opus-4-7", "provider": "anthropic"},
  {"name": "claude-sonnet-4-6", "provider": "anthropic"},
  {"name": "claude-haiku-4-5", "provider": "anthropic"},
  {"name": "gpt-5", "provider": "openai"},
  {"name": "gpt-5-mini", "provider": "openai"},
  {"name": "o4", "provider": "openai"},
  {"name": "o4-mini", "provider": "openai"},
  {"name": "gemini-2.5-pro", "provider": "google"},
  {"name": "gemini-2.5-flash", "provider": "google"},
  {"name": "llama-4", "provider": "meta"},
  {"name": "mistral-large-3", "provider": "mistral"},
  {"name": "grok-4", "provider": "xai"},
  {"name": "command-r-plus", "provider": "cohere"},
  {"name": "qwen3-coder", "provider": "alibaba"}
]
```

14 models — equal Anthropic and OpenAI representation. ~3-5 minutes
of research per card on average → seed run is a 30-60 minute one-off
operation. Users can extend the JSON.

## Storage and library

**Default path**: `~/.claude/model-cards/<provider>/<model-name>.md`

**Override mechanisms** (in priority order):

1. `--out <path>` flag on `create` (per-invocation override)
2. `MODEL_CARDS_DIR` environment variable (session-level)
3. Default: `~/.claude/model-cards/`

**Provider name resolution**: the agent infers from research; for
ambiguous cases the command prompts the user during the review step
to confirm provider directory.

**Library structure**: just folders. No index file, no metadata
aggregation, no browse surface — YAGNI applies; add only when real
demand surfaces.

## Marketplace integration

`.claude-plugin/marketplace.json` gains a second `plugins[]` entry.

**Before**:

```json
{
  "name": "ai-literacy-superpowers",
  "version": "0.2.3",
  "plugin_version": "0.31.1",
  "plugins": [
    {"name": "ai-literacy-superpowers", "source": "./ai-literacy-superpowers", "version": "0.31.1"}
  ]
}
```

**After**:

```json
{
  "name": "ai-literacy-superpowers",
  "version": "0.3.0",
  "plugin_version": "0.31.1",
  "plugins": [
    {"name": "ai-literacy-superpowers", "source": "./ai-literacy-superpowers", "version": "0.31.1"},
    {"name": "model-cards", "source": "./model-cards", "version": "0.1.0", "description": "Researches and authors Mitchell-extended model cards from a model name."}
  ]
}
```

**Listing version**: 0.2.3 → 0.3.0 (per CLAUDE.md "Marketplace
Versioning": adding a plugin entry to the array bumps the listing
version).

**`plugin_version` field**: kept, points at the canonical
`ai-literacy-superpowers` plugin (Option A). The asymmetry — one
plugin is "primary" while others sit alongside — is honest and
backward-compatible. Schema cleanup deferred to a separate issue so
this PR's scope stays clean.

## Plugin self-versioning

`model-cards/.claude-plugin/plugin.json`:

```json
{
  "name": "model-cards",
  "version": "0.1.0",
  "description": "Researches and authors Mitchell-extended model cards from a model name. Tiered source strategy (provider docs → HuggingFace → arXiv → web). Hybrid review-before-commit flow.",
  "author": {"name": "Russ Miles"},
  "keywords": ["model-cards", "model-research", "ai-evaluation", "mitchell-2019", "ai-literacy"]
}
```

Pre-1.0 semver discipline (mirrors `ai-literacy-superpowers`):

- 0.MINOR.0 — new commands, agents, or behavioural changes
- 0.x.PATCH — bug fixes, doc-only changes

`model-cards/CHANGELOG.md` is created at v0.1.0 with the initial release.

## Testing strategy

Per Q5/3 decision: no new executable test runner.

- **markdownlint** runs over the new plugin's templates and any
  committed seed cards (existing CI applies if path globs include
  `model-cards/**/*.md`; if not, this PR adds the include)
- **Manual smoke test before merge**: run
  `/model-card create claude-opus-4-7 --provider anthropic` in dev
  environment; verify the produced card has populated sections,
  real citations, and writes to the expected library path
- **Manual seed test**: run `/model-card seed` against a *trimmed*
  seed list (3 models) in dev; verify all 3 land in the library
- **No new harness for the plugin** — the existing repo-level harness
  covers what's needed (markdownlint, gitleaks, ShellCheck where
  applicable). YAGNI applies.

## Risks and open questions

- **Token cost of seed run** — 14 models at ~3-5 min of research each
  is non-trivial. The user opts in once; per-card review is skipped
  for seed. If actual cost is significantly higher than estimated,
  add an opt-in subset to seed (e.g., `--providers anthropic,openai`).
- **Provider docs change shape** — the agent's tier-1 strategy
  depends on stable provider docs URLs. If a provider restructures
  their docs site, the agent falls back to web search. Worth a
  reflection capture if this becomes a recurring problem.
- **Knowledge-cutoff hallucination risk** — research about new
  models may pull stale information. Mitigation: the
  `last_researched` frontmatter date makes staleness visible;
  per-claim citations make verification cheap.
- **Frontier seed list ages** — the `frontier-models.json` list is
  a maintainable artefact, not a contract. Update when new models
  ship. Worth a reflection if the cadence becomes onerous.

## Process

This spec is the first commit on branch `model-cards-plugin`. After
spec approval the project's full feature pipeline applies:

1. **Spec-time `/diaboli`** — adversarial review of the spec
   producing
   `docs/superpowers/objections/2026-04-29-model-cards-plugin-design.md`
2. **Adjudicate** — resolve every disposition (no `pending` values)
3. **`/choice-cartograph`** — surface implicit decision terrain;
   produces `docs/superpowers/stories/2026-04-29-model-cards-plugin-design.md`
4. **Adjudicate stories** — every story has `accepted` / `revisit`
   / `promoted` disposition
5. **Plan via writing-plans skill** — implementation plan
6. **Implementation**
7. **Code-time `/diaboli`** — adversarial review of implementation
8. **Adjudicate code-mode objections**
9. **Integration** — open PR, watch CI, merge

Steps 1-4 must complete before step 5 to avoid wasted plan work if
spec changes.

## Tracking issues to create after spec commit

| Issue | Type | Purpose |
| --- | --- | --- |
| `/model-card list` subcommand | feature | Browse / list cards in the library; designed and implemented after v0.1.0 ships and we have real cards |
| `/model-card compare <a> <b>` subcommand | feature | Side-by-side comparison of two model cards; designed after v0.1.0 |
| `/model-card refresh <name>` subcommand | feature | Re-research a specific card; designed after v0.1.0 (informed by observed staleness in real use) |
| Explore top-level `plugin_version` removal in marketplace.json | chore | Schema cleanup: remove ambiguous root field; update version-check.yml to read per-plugin entries; update HARNESS.md / CLAUDE.md / ONBOARDING.md / .windsurf/rules/constraints.md docs |

## Cross-references

- `2026-04-29` REFLECTION_LOG entry on the abandoned model-cards
  exploration in the existing `ai-literacy-superpowers` plugin —
  Option F decision and conditions for revisit (Driver 2 from the
  reflection's Conditions for Revisit list — "downstream consumer
  asks for it with a concrete use case" — has been satisfied: the
  user is the user; this spec is the implementation)
- `ai-literacy-superpowers/skills/model-sovereignty/SKILL.md` —
  decision-layer companion skill; this plugin extends the
  framework's model coverage from "which model to use" to "what
  is this model"
- `ai-literacy-superpowers/MODEL_ROUTING.md` — per-agent model
  routing with sovereignty considerations; cards from this plugin
  inform routing decisions
- Mitchell, M. et al. (2019). "Model Cards for Model Reporting."
  ACM FAccT — the canonical reference for the 9-section framework
  this plugin extends
