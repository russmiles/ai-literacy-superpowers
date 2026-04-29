# model-cards plugin v0.1.0 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a sister plugin (`model-cards`) in the existing marketplace repo that researches and authors Mitchell-extended model cards from a model name, ships with a 14-model frontier seed list, and integrates cleanly with the existing marketplace and CI without disrupting `ai-literacy-superpowers`.

**Architecture:** The plugin lives at `model-cards/` next to `ai-literacy-superpowers/` with the same layout convention (`.claude-plugin/`, `agents/`, `commands/`, `skills/`, `templates/`, `seed/`, `CHANGELOG.md`, `README.md`). One agent (`model-card-researcher`) and one command (`/model-card create|seed` with subcommand dispatch). Cards land at `~/.claude/model-cards/<provider>/<model-name>.md` by default. Marketplace listing bumps to v0.3.0; per-plugin version-consistency check extended to enumerate `plugins[]`.

**Tech Stack:** Markdown templates, YAML frontmatter, JSON config, bash for any glue scripts, GitHub Actions (existing workflows extended). No new test framework — relies on markdownlint + manual integration smoke tests, consistent with the repo's existing TEST_STRATEGY.

**Spec:** `docs/superpowers/specs/2026-04-29-model-cards-plugin-design.md`
**Diaboli (adjudicated)**: `docs/superpowers/objections/model-cards-plugin-design.md`
**Stories (adjudicated)**: `docs/superpowers/stories/model-cards-plugin-design.md`

---

## File Structure

| File | Action | Responsibility |
|---|---|---|
| `model-cards/.claude-plugin/plugin.json` | Create | Plugin manifest, v0.1.0 |
| `model-cards/README.md` | Create | Plugin landing page; what it does, install, two subcommands |
| `model-cards/CHANGELOG.md` | Create | Starts with v0.1.0 entry |
| `model-cards/templates/MODEL_CARD.md` | Create | 10-section Mitchell-extended template |
| `model-cards/skills/model-cards/SKILL.md` | Create | Framework guidance: when each section applies, citation discipline, honesty rules |
| `model-cards/agents/model-card-researcher.agent.md` | Create | Charter: tiered sources, per-section research, citation discipline, card-level + claim-level honesty rules |
| `model-cards/commands/model-card.md` | Create | `/model-card create|seed` subcommand dispatch with hybrid review-before-commit |
| `model-cards/seed/frontier-models.json` | Create | 14-model frontier seed list |
| `.claude-plugin/marketplace.json` | Modify | Add second `plugins[]` entry; bump listing version 0.2.3 → 0.3.0 |
| `.github/workflows/version-check.yml` | Modify | Enumerate plugins via `marketplace.json` `plugins[]` array (per O12 disposition) |
| `AGENTS.md` | Modify | New ARCH_DECISIONS entry promoting the trust-architecture pattern (per stories 7+8 promotion) |

---

## Task 1: Plugin scaffold — `plugin.json`, `CHANGELOG.md`, `README.md`

**Files:**

- Create: `model-cards/.claude-plugin/plugin.json`
- Create: `model-cards/CHANGELOG.md`
- Create: `model-cards/README.md`

- [ ] **Step 1: Create `model-cards/.claude-plugin/plugin.json`**

```json
{
  "name": "model-cards",
  "version": "0.1.0",
  "description": "Researches and authors Mitchell-extended model cards from a model name. Tiered source strategy (provider docs → HuggingFace → arXiv → web). Hybrid review-before-commit flow.",
  "author": {"name": "Russ Miles"},
  "keywords": ["model-cards", "model-research", "ai-evaluation", "mitchell-2019", "ai-literacy"]
}
```

- [ ] **Step 2: Verify JSON well-formed**

Run: `jq . model-cards/.claude-plugin/plugin.json > /dev/null && echo OK`
Expected: `OK`

- [ ] **Step 3: Create `model-cards/CHANGELOG.md`**

```markdown
# Changelog

## 0.1.0 — 2026-04-29

### Added

- Initial release. `/model-card create <name>` for research-and-author flow with
  hybrid review-before-commit. `/model-card seed` for bulk-populate from the
  shipped 14-model frontier seed list.
- Mitchell-extended card template (9 canonical sections + Operational Details).
- Tiered source strategy: provider docs → HuggingFace → arXiv → web search.
- Per-claim citation format: `[T<n>.<m>]` resolving via per-card frontmatter.
- Default library at `~/.claude/model-cards/<provider>/<model-name>.md`;
  configurable via `--out` flag (directory override) and `MODEL_CARDS_DIR` env var.
- Spec, diaboli adjudication, and choice-cartograph stories preserved at
  `docs/superpowers/specs/2026-04-29-model-cards-plugin-design.md` and the
  matching objections / stories records.
```

- [ ] **Step 4: Create `model-cards/README.md`**

```markdown
# model-cards

Research and author Mitchell-extended model cards from a model name.

A sister plugin to [ai-literacy-superpowers](../ai-literacy-superpowers/) in
the same marketplace. Aimed at evaluators researching new models.

## What it does

- `/model-card create <model-name> [--provider X] [--out path]` — researches
  the model through a tiered source strategy (provider docs → HuggingFace →
  arXiv → web), produces a draft card, presents a review summary, and (on
  accept) writes the card to your library.
- `/model-card seed` — populates the library with cards for a shipped list of
  14 frontier LLMs from major providers.

## Install

```bash
# In Claude Code
claude plugin install model-cards@ai-literacy-superpowers

# In Copilot CLI
copilot plugin install model-cards@ai-literacy-superpowers
```

## Library location

Default: `~/.claude/model-cards/<provider>/<model-name>.md`

Override with the `--out` flag (directory override; cards still land beneath
it as `<provider>/<model-name>.md`) or the `MODEL_CARDS_DIR` env var.

## Card format

10-section Mitchell-extended:

1. Model Details
2. Intended Use
3. Factors
4. Metrics
5. Evaluation Data
6. Training Data
7. Quantitative Analyses
8. Ethical Considerations
9. Caveats and Recommendations
10. Operational Details (this plugin's extension — pricing, context window,
    knowledge cutoff, supported APIs/SDKs, latency, tool/structured-output
    support, function calling, fine-tuning availability, rate limit notes)

Cards include per-claim citations of the form `[T<n>.<m>]` where `n` is the
source tier (1 = provider docs, 2 = HuggingFace, 3 = arXiv, 4 = web).

## Honesty rules

- Sections that the agent cannot find information for are filled with "Not
  publicly available" — never fabricated.
- If tier-1 and tier-2 are both silent on the model itself (the agent
  cannot confirm the model exists), the agent refuses to create the card and
  surfaces the result to the user. Cards are not produced for non-existent or
  unconfirmed model names.
- If a tier-4 (web) claim conflicts with a tier-1 (provider docs) claim,
  tier-1 wins; the conflict is flagged in Caveats.

## Roadmap

- `/model-card list` — browse the library (issue #233)
- `/model-card compare <a> <b>` — side-by-side card comparison (issue #234)
- `/model-card refresh <name>` — re-research a specific card (issue #235)
```

- [ ] **Step 5: Verify markdownlint**

Run: `npx markdownlint-cli2 "model-cards/**/*.md"`
Expected: no errors.

- [ ] **Step 6: Commit**

```bash
git add model-cards/.claude-plugin/plugin.json model-cards/CHANGELOG.md model-cards/README.md
git commit -m "model-cards: scaffold plugin manifest, CHANGELOG, README (v0.1.0)"
```

---

## Task 2: Card template — `MODEL_CARD.md`

**Files:**

- Create: `model-cards/templates/MODEL_CARD.md`

- [ ] **Step 1: Create the template**

```markdown
---
model_name: <provider>/<model-name>
provider: <Anthropic | OpenAI | Google | Meta | Mistral | xAI | Cohere | Alibaba | other>
model_version: <as-stated-by-provider>
last_researched: YYYY-MM-DD
card_version: 0.1.0
researcher: model-card-researcher (claude-opus-4-7[1m])
sources:
  - tier: 1
    url: <provider docs URL>
    fetched: YYYY-MM-DD
  - tier: 2
    url: <huggingface URL or "n/a">
    fetched: YYYY-MM-DD
  - tier: 3
    url: <arxiv URL or "n/a">
    fetched: YYYY-MM-DD
  - tier: 4
    url: <web URL or "n/a">
    fetched: YYYY-MM-DD
---

# Model Card: <provider>/<model-name>

## 1. Model Details

What this model is, who released it, when, what kind of model it is. Cite
provider-stated identity, release date, model family, parameter count if
disclosed.

## 2. Intended Use

Primary uses, primary users, out-of-scope uses (per the provider's published
statements).

## 3. Factors

Relevant subgroups, environmental factors, instrumentation factors. Often
sparse for proprietary API-served models — fill with "Not publicly available"
where the provider has not disclosed.

## 4. Metrics

Performance measures the provider reports. Cite each metric with its source
tier; prefer tier-1 (provider docs) and tier-3 (release paper).

## 5. Evaluation Data

Datasets used to evaluate (per the provider's published statements). Often
"Not publicly available" for proprietary models — say so explicitly.

## 6. Training Data

Datasets used to train (per the provider's published statements). Frequently
"Not publicly available" for proprietary models — say so explicitly.

## 7. Quantitative Analyses

Disaggregated performance, where provider has published this. Cite metrics
table from release paper or provider docs; record the date of the analysis.

## 8. Ethical Considerations

Risks, mitigations, known failure modes — preferring the release paper as
primary source (tier 3); supplemented by provider statements (tier 1) and
independent evaluations (tier 4) where relevant.

## 9. Caveats and Recommendations

What this card cannot tell you (sections marked "Not publicly available" and
why). Recommendations for use given the model's documented strengths and
limitations. Conflicts between tier-1 and tier-4 sources are recorded here.

## 10. Operational Details

Best-effort structured fields; missing values are written as "Not publicly
available" rather than omitted:

- **Pricing** — input/output cost per million tokens; pricing tier; as-of
  date. Cite the pricing page (tier 1).
- **Context window** — maximum input + output tokens.
- **Knowledge cutoff** — provider-stated training cutoff date.
- **Supported APIs/SDKs** — provider's API name(s); language SDKs; OpenAI
  Chat Completions compatibility if applicable.
- **Latency tier** — provider's stated latency tier or category, if any.
- **Tool / structured-output support** — function calling, JSON mode, tool
  use, parallel tool calls.
- **Function calling** — supported, parallel-supported, schema format.
- **Fine-tuning availability** — yes/no/limited; cite the fine-tuning docs
  page if available.
- **Rate-limit notes** — provider-published rate limit tiers or quotas.
```

- [ ] **Step 2: Verify markdownlint**

Run: `npx markdownlint-cli2 model-cards/templates/MODEL_CARD.md`
Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add model-cards/templates/MODEL_CARD.md
git commit -m "model-cards: 10-section Mitchell-extended template"
```

---

## Task 3: Seed list — `frontier-models.json`

**Files:**

- Create: `model-cards/seed/frontier-models.json`

- [ ] **Step 1: Create the seed list**

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

- [ ] **Step 2: Verify JSON well-formed and structurally sound**

```bash
jq '. | length' model-cards/seed/frontier-models.json
jq '.[].name' model-cards/seed/frontier-models.json | wc -l
jq '.[].provider' model-cards/seed/frontier-models.json | sort -u
```

Expected: `14`, `14`, and a list of 8 unique provider strings.

- [ ] **Step 3: Commit**

```bash
git add model-cards/seed/frontier-models.json
git commit -m "model-cards: 14-model frontier seed list"
```

---

## Task 4: Skill — Mitchell-extended framework guidance

**Files:**

- Create: `model-cards/skills/model-cards/SKILL.md`

- [ ] **Step 1: Create the skill**

```markdown
---
name: model-cards
description: Use when authoring or interpreting Mitchell-extended model cards in this plugin. Covers when each of the 10 sections applies, the citation discipline, the honesty rules (claim-level and card-level), and the tiered source strategy. Reference for the model-card-researcher agent and the /model-card command.
---

# Mitchell-Extended Model Cards

This plugin produces 10-section model cards: Mitchell et al.'s 9 canonical
sections plus an "Operational Details" 10th section for the consumer-evaluator
audience. This skill is the reference for what each section is for and how
to fill it honestly.

## The ten sections

### 1. Model Details

What the model IS — name, provider, family, release date, parameter count
where disclosed. Tier 1 (provider docs) is primary; tier 2 (HuggingFace) is
secondary for open-source / fine-tuned models.

### 2. Intended Use

What the model is for — primary uses, intended users, explicitly out-of-scope
uses. The provider's documentation usually makes this explicit; quote it
faithfully and cite.

### 3. Factors

Subgroups, environmental factors, instrumentation. Often sparse for
proprietary API-served models — write "Not publicly available" rather than
fabricate.

### 4. Metrics

Performance measures the provider reports. Distinguish provider-reported
benchmarks from independent evaluations (tier 1 vs tier 4).

### 5. Evaluation Data

Datasets used to evaluate. Frequently "Not publicly available" for
proprietary models. Tier 3 (release paper) is the most likely source.

### 6. Training Data

Datasets used to train. Almost always "Not publicly available" for proprietary
models — say so. Tier 3 is the only source likely to disclose.

### 7. Quantitative Analyses

Disaggregated performance — by demographic, by task category, by language.
Tier 3 (release paper) is primary.

### 8. Ethical Considerations

Risks, mitigations, known failure modes. Tier 3 is the most honest source
(release papers are usually more frank than marketing pages); tier 1 is
secondary; tier 4 (independent evaluations) is tertiary but valuable for
reality-check.

### 9. Caveats and Recommendations

The "what this card cannot tell you" section. Lists which sections came up
"Not publicly available" and why. Records conflicts between tiers.
Recommendations for use given the model's documented profile.

### 10. Operational Details

This plugin's extension. Best-effort structured fields:

- Pricing (input/output per million tokens)
- Context window
- Knowledge cutoff
- Supported APIs/SDKs
- Latency tier
- Tool / structured-output support
- Function calling
- Fine-tuning availability
- Rate-limit notes

Each field gets "Not publicly available" if absent; the field is never
omitted. This makes downstream comparison (`/model-card compare`) reliable.

## Citation discipline

Every factual claim ends with `[T<n>.<m>]` where:

- `n` is the source tier: 1 = provider docs, 2 = HuggingFace, 3 = arXiv,
  4 = web search
- `m` is the source index within that tier (1, 2, 3...)

Example:

```text
Knowledge cutoff: January 2026 [T1.1]. Context window: 1M tokens [T1.2].
Pricing: $5/$25 per million tokens (input/output) at standard tier [T1.3].
```

URLs for each citation resolve via the per-card frontmatter `sources` block.

## Honesty rules

### Claim-level

- "Not publicly available" is the canonical answer when tier-1 is silent
  and lower tiers cannot confirm. Never fabricate.
- "Per the provider's published statements" framing is preferred over
  assertion — preserves the source-trust chain.
- If a tier-4 web claim conflicts with a tier-1 provider claim, tier-1 wins;
  the conflict is flagged in Section 9 (Caveats).

### Card-level

- If tier-1 (provider docs) AND tier-2 (HuggingFace) are both silent on the
  model's existence — the agent cannot confirm the model exists at all — the
  agent refuses to create the card and surfaces the result to the dispatching
  command. The command reports back to the user. **Cards are not produced
  for non-existent or unconfirmed model names.** This rule prevents
  authoritative-looking cards for hallucinated models.

## Tiered source strategy

| Tier | Source | Used for |
|---|---|---|
| 1 | Provider docs | Model Details, Intended Use, Operational Details |
| 2 | HuggingFace | Open-source / fine-tuned models; fallback for tier-1 gaps |
| 3 | arXiv release paper | Factors, Metrics, Evaluation Data, Training Data, Quantitative Analyses, Ethical Considerations |
| 4 | Web search | Anything tiers 1-3 don't cover; independent evaluations |

The agent researches **section-by-section** using each section's primary
tier (see the table in `agents/model-card-researcher.agent.md`). This is
more efficient than fetching all sources upfront.

## When to use this skill

- Authoring a card by hand (without the agent)
- Interpreting a card (which sections to trust most)
- Designing extensions to the card schema (e.g. adding fields to Section 10)
- Building tooling that consumes cards (e.g. the future `/model-card compare`)
```

- [ ] **Step 2: Verify markdownlint**

Run: `npx markdownlint-cli2 model-cards/skills/model-cards/SKILL.md`
Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add model-cards/skills/model-cards/SKILL.md
git commit -m "model-cards: skill — Mitchell-extended framework guidance"
```

---

## Task 5: Research agent — `model-card-researcher.agent.md`

**Files:**

- Create: `model-cards/agents/model-card-researcher.agent.md`

- [ ] **Step 1: Create the agent definition**

```markdown
---
name: model-card-researcher
description: Use to research a model and produce a Mitchell-extended model card. Given a model name (and optional provider hint), the agent applies a tiered source strategy and returns the full card content. Refuses to produce a card when tier-1 + tier-2 are both silent on model existence — never fabricates a card for an unconfirmed model. Output is a markdown string returned to the dispatching command; the command writes the file.
tools: WebFetch, WebSearch, Read, Write, Glob, Grep
model: inherit
---

# Charter

You are the **model-card-researcher**. Given a model name (and optionally a
provider hint), you produce a Mitchell-extended model card by researching
the model through a tiered source strategy. You cite every factual claim.
You write "Not publicly available" rather than fabricate.

## Inputs

- **Model name** (required) — e.g. `claude-opus-4-7`, `meta-llama/llama-4`,
  `gpt-5-mini`
- **Provider hint** (optional) — e.g. `anthropic`, `openai`, `huggingface`,
  `meta`. If absent, you infer from the model name.

## Output

A single markdown string containing the full card content (frontmatter + 10
sections per the template at `model-cards/templates/MODEL_CARD.md`).

You do **not** write the file. The dispatching command persists the output
after a human-in-the-loop review step.

## Tools

`WebFetch`, `WebSearch`, `Read`, `Write`, `Glob`, `Grep`. No `Edit`, no
`Bash`. The trust boundary is "research and emit content"; persistence is
the dispatcher's job.

## Tiered source strategy

| Tier | Source | Discovery |
|---|---|---|
| 1 | Provider docs | URL inferred from this provider→docs-root mapping |
| 2 | HuggingFace | `https://huggingface.co/<owner>/<model>` if model is on HF |
| 3 | arXiv release paper | `WebSearch` for `"<model-name>" arxiv` |
| 4 | Web search | `WebSearch` with explicit queries; prefer recent results |

### Provider→docs-root mapping (tier 1)

- `anthropic` → `https://docs.anthropic.com`
- `openai` → `https://platform.openai.com/docs/models`
- `google` → `https://ai.google.dev/gemini-api/docs/models`
- `meta` → `https://ai.meta.com/llama` and the model's GitHub repo
- `mistral` → `https://docs.mistral.ai`
- `xai` → `https://docs.x.ai`
- `cohere` → `https://docs.cohere.com`
- `alibaba` → `https://qwenlm.github.io` or the relevant model's docs page
- For any other provider, search-discover via `WebSearch` for
  `"<provider>" "<model-name>" docs`.

### Per-section primary source

| Section | Primary | Fallback |
|---|---|---|
| Model Details | Tier 1 | Tier 2 → 4 |
| Intended Use | Tier 1 | Tier 2 → 4 |
| Factors | Tier 3 | Tier 1 → 2 |
| Metrics | Tier 1 + Tier 3 | — |
| Evaluation Data | Tier 3 | Tier 1 |
| Training Data | Tier 3 | Tier 1 (often "Not publicly available") |
| Quantitative Analyses | Tier 3 | Tier 1 |
| Ethical Considerations | Tier 3 + Tier 1 | Tier 4 |
| Caveats and Recommendations | Synthesised | — |
| Operational Details | Tier 1 | Tier 4 |

## Honesty rules

### Claim-level

- "Not publicly available" is the canonical answer when tier-1 is silent
  and lower tiers cannot confirm. Never fabricate.
- "Per the provider's published statements" framing is preferred over
  assertion — preserves the source-trust chain.
- If a tier-4 web claim conflicts with a tier-1 provider claim, tier-1 wins;
  the conflict is flagged in Section 9 (Caveats).

### Card-level (model existence check)

If tier-1 (provider docs) AND tier-2 (HuggingFace) are both silent on the
model's existence — neither has a page, doc, or model card matching the
input name — you **refuse to produce the card**. Return:

```text
REFUSED: Could not confirm existence of model "<name>" via tier-1
(provider docs) or tier-2 (HuggingFace). Searched: <list of URLs / queries>.
The model may not exist under this name, may have been retired, or may
be too recent for available sources. The dispatching command should
surface this to the user before any file is written.
```

The dispatcher will not write a file when this REFUSED string is the agent
output. This prevents authoritative-looking cards for hallucinated or
non-existent models.

## Citation format

Every factual claim ends with `[T<n>.<m>]` where:

- `n` is the source tier (1-4)
- `m` is the source index within that tier (1, 2, 3...)

URLs resolve via the frontmatter `sources` block of the card you produce.
Aggregate sources at top of the card.

## Output structure

Use the exact 10-section structure from `model-cards/templates/MODEL_CARD.md`.
Populate frontmatter:

- `model_name`
- `provider`
- `model_version` (use the input model name if provider doesn't disclose
  a separate version)
- `last_researched` (today's date in YYYY-MM-DD)
- `card_version` (always `0.1.0` for this plugin's v0.1.0)
- `researcher` (always `model-card-researcher (claude-opus-4-7[1m])`)
- `sources` (full URL per tier consulted; "n/a" for tiers not consulted)

## Anti-patterns

- Fabricating a citation. If you didn't fetch a URL, don't cite it.
- Producing a card after the model-existence check fails. Return the REFUSED
  string instead.
- Writing files. Your tools include Write but the dispatcher writes; the
  Write capability is reserved for one specific use only: writing your
  output to a temp path the dispatcher will read. **Default behaviour is to
  return content as your final message** — only use Write if the dispatcher
  has explicitly asked for a temp-file output.
- Dropping a section because it came up sparse. Every section appears in
  every card; sparse sections are filled with "Not publicly available."
```

- [ ] **Step 2: Verify YAML frontmatter parseable**

Run:

```bash
python3 -c "
import yaml
content = open('model-cards/agents/model-card-researcher.agent.md').read()
fm = yaml.safe_load(content.split('---', 2)[1])
print('Name:', fm['name'])
print('Tools:', fm['tools'])
print('Model:', fm['model'])
"
```

Expected:

```text
Name: model-card-researcher
Tools: WebFetch, WebSearch, Read, Write, Glob, Grep
Model: inherit
```

- [ ] **Step 3: Verify markdownlint**

Run: `npx markdownlint-cli2 model-cards/agents/model-card-researcher.agent.md`
Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add model-cards/agents/model-card-researcher.agent.md
git commit -m "model-cards: model-card-researcher agent (tiered sources, honesty rules)"
```

---

## Task 6: Command — `/model-card create|seed`

**Files:**

- Create: `model-cards/commands/model-card.md`

- [ ] **Step 1: Create the command**

```markdown
---
name: model-card
description: Research and author Mitchell-extended model cards. /model-card create <name> for one-card hybrid review-before-commit flow; /model-card seed for bulk-populate from the shipped frontier seed list.
---

# /model-card \<subcommand\> [args]

Subcommands:

- `create <model-name> [--provider X] [--out path]`
- `seed [--force]`

Future subcommands tracked as issues:

- `/model-card list` — issue #233
- `/model-card compare <a> <b>` — issue #234
- `/model-card refresh <name>` — issue #235

## Subcommand: `create`

### Usage

```text
/model-card create <model-name> [--provider X] [--out path]
```

### Flow

1. **Parse args**
   - `model-name` (required, positional)
   - `--provider` (optional hint; if absent, agent infers)
   - `--out` (optional library directory override; cards still land beneath
     it as `<provider>/<model-name>.md`)

2. **Resolve target path**
   - Default: `~/.claude/model-cards/<provider>/<model-name>.md`
   - If `MODEL_CARDS_DIR` env var is set, use it as the library root
   - If `--out` flag is passed, use it as the library root (highest priority)
   - The provider sub-directory and `<model-name>.md` filename always apply
     beneath whatever library root was resolved

3. **Check for existing card at target path**
   - If present, ask the user: `overwrite / skip / load-existing-as-base`
   - On `skip`, abort the flow with no file change
   - On `load-existing-as-base`, pass the existing card content to the agent
     as starting context

4. **Dispatch the `model-card-researcher` agent**
   - Pass the model name and provider hint
   - Agent returns either:
     - A full markdown card content string, OR
     - A `REFUSED:` string indicating the model-existence check failed

5. **Handle REFUSED**
   - If the agent's output starts with `REFUSED:`, surface the refusal
     reason to the user verbatim and abort the flow with no file written.

6. **Show review summary**
   - Sources used per section (tier breakdown — counts of `[T1.x]`,
     `[T2.x]`, `[T3.x]`, `[T4.x]` citations)
   - Sections that came up thin — list of section numbers (1-10) where
     "Not publicly available" appears at section level
   - Top 3 most-cited claims by raw citation count, with their source URLs
   - Estimated token cost of the research (rough — sum of fetched-content
     sizes at ~4 chars/token approximation)

7. **Ask for disposition**
   - `accept` — write the card to target path, confirm with full path
   - `edit` — open the draft in `$EDITOR` (or `vi` if unset), then re-prompt
     with the edited content
   - `re-run-section <N>` — re-dispatch the agent with a section-specific
     prompt focusing on template section number N (1-10); replace just that
     section in the draft, then re-prompt
   - `abort` — discard the draft, no file written

8. **On accept**
   - `mkdir -p $(dirname target_path)`
   - Write the card content to `target_path`
   - Print: `Card written: <full_path>`

### Specification picks (from spec O9 disposition)

- `--out path` — directory override; card filename and provider sub-dir
  still apply beneath
- Provider name resolution — agent-inferred; if ambiguous, command prompts
  user during step 6 to confirm provider sub-directory before write
- `re-run-section <N>` — N is the template section number 1-10
- "Top 3 most-cited claims" — raw citation count per claim

## Subcommand: `seed`

### Usage

```text
/model-card seed [--force]
```

### Flow

1. **Read seed list**
   - Source: `${CLAUDE_PLUGIN_ROOT}/seed/frontier-models.json`
   - Format: `[{"name": "...", "provider": "..."}, ...]`

2. **Show user the list and total count**

3. **Ask once for confirmation**
   - `Research <N> cards into <library-root>? [y/N]`
   - On `y`, proceed
   - On any other input, abort

4. **For each model in list (sequential)**
   - Resolve target path (as in `create` step 2)
   - If card exists at target path AND `--force` is not set, skip with
     one-line message
   - Dispatch `model-card-researcher`
   - If REFUSED, log skip with reason (one line); continue to next model
   - Else write card to target path; log creation (one line)

5. **Print summary**
   - Created: N
   - Skipped (existed): N
   - Skipped (refused): N
   - Failed (other): N

### Note on resumability

`seed` is idempotent for the common-case "ran partially, want to retry" — the
existence check at step 4 skips already-written cards. To re-research existing
cards, use `--force` (overwrites) or run `/model-card create <name>` per model
(interactive review).

If failure modes prove common in real use, `--resume` and `--retry-failed`
flags can be added in a v0.1.x patch without spec rework.
```

- [ ] **Step 2: Verify YAML frontmatter parseable**

Run:

```bash
python3 -c "
import yaml
content = open('model-cards/commands/model-card.md').read()
fm = yaml.safe_load(content.split('---', 2)[1])
print('Name:', fm['name'])
"
```

Expected: `Name: model-card`

- [ ] **Step 3: Verify markdownlint**

Run: `npx markdownlint-cli2 model-cards/commands/model-card.md`
Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add model-cards/commands/model-card.md
git commit -m "model-cards: /model-card command (create + seed subcommands)"
```

---

## Task 7: Marketplace integration — second `plugins[]` entry + listing version bump

**Files:**

- Modify: `.claude-plugin/marketplace.json`

- [ ] **Step 1: Read current state**

Run: `cat .claude-plugin/marketplace.json`

Expected to show:

```json
{
  "name": "ai-literacy-superpowers",
  "version": "0.2.3",
  "plugin_version": "0.31.1",
  "plugins": [
    {"name": "ai-literacy-superpowers", "source": "./ai-literacy-superpowers", "version": "0.31.1", "...": "..."}
  ]
}
```

- [ ] **Step 2: Edit `.claude-plugin/marketplace.json`**

Change `version` from `0.2.3` to `0.3.0` (per CLAUDE.md "Marketplace
Versioning": adding a plugin entry to the array bumps the listing version).

Append a second entry to the `plugins` array:

```json
    {
      "name": "model-cards",
      "source": "./model-cards",
      "description": "Researches and authors Mitchell-extended model cards from a model name.",
      "version": "0.1.0"
    }
```

Final shape:

```json
{
  "name": "ai-literacy-superpowers",
  "owner": {"name": "Russ Miles"},
  "version": "0.3.0",
  "plugin_version": "0.31.1",
  "description": "...",
  "repository": {"type": "git", "url": "https://github.com/Habitat-Thinking/ai-literacy-superpowers"},
  "plugins": [
    {"name": "ai-literacy-superpowers", "source": "./ai-literacy-superpowers", "description": "...", "version": "0.31.1"},
    {"name": "model-cards", "source": "./model-cards", "description": "Researches and authors Mitchell-extended model cards from a model name.", "version": "0.1.0"}
  ]
}
```

- [ ] **Step 3: Verify JSON well-formed**

Run: `jq . .claude-plugin/marketplace.json > /dev/null && echo OK`
Expected: `OK`

- [ ] **Step 4: Verify both plugins listed**

Run: `jq '.plugins[] | .name' .claude-plugin/marketplace.json`
Expected:

```text
"ai-literacy-superpowers"
"model-cards"
```

- [ ] **Step 5: Commit**

```bash
git add .claude-plugin/marketplace.json
git commit -m "marketplace: add model-cards plugin (listing v0.2.3 → v0.3.0)"
```

---

## Task 8: CI — extend `version-check.yml` to enumerate plugins

**Files:**

- Modify: `.github/workflows/version-check.yml`

Per the spec's adjudication of O12: the existing workflow reads
`ai-literacy-superpowers/.claude-plugin/plugin.json` singular. It needs to
read each plugin enumerated in `marketplace.json`'s `plugins[]` array.

- [ ] **Step 1: Read current state**

Run: `cat .github/workflows/version-check.yml | head -60`

Confirm that `Extract versions from all locations` step reads only
`ai-literacy-superpowers/.claude-plugin/plugin.json`.

- [ ] **Step 2: Edit `.github/workflows/version-check.yml`**

Replace the `Extract versions from all locations` step's `PLUGIN_VERSION`
extraction logic with multi-plugin enumeration. Specifically — change this
block:

```yaml
          # plugin.json version
          PLUGIN_VERSION=$(grep '"version"' ai-literacy-superpowers/.claude-plugin/plugin.json | sed 's/.*"version": "\(.*\)".*/\1/')
          echo "plugin=$PLUGIN_VERSION" >> "$GITHUB_OUTPUT"
```

to:

```yaml
          # ai-literacy-superpowers plugin.json version (canonical plugin)
          PLUGIN_VERSION=$(grep '"version"' ai-literacy-superpowers/.claude-plugin/plugin.json | sed 's/.*"version": "\(.*\)".*/\1/')
          echo "plugin=$PLUGIN_VERSION" >> "$GITHUB_OUTPUT"

          # All plugins enumerated from marketplace.json plugins[]
          # Each entry's source path + .claude-plugin/plugin.json version is verified
          # against its marketplace.json plugins[] entry's version (per-plugin sync).
          PLUGIN_NAMES=$(jq -r '.plugins[].name' .claude-plugin/marketplace.json)
          PLUGIN_MISMATCHES=""
          for name in $PLUGIN_NAMES; do
            source=$(jq -r --arg n "$name" '.plugins[] | select(.name == $n) | .source' .claude-plugin/marketplace.json)
            mp_version=$(jq -r --arg n "$name" '.plugins[] | select(.name == $n) | .version' .claude-plugin/marketplace.json)
            pj_version=$(jq -r '.version' "${source}/.claude-plugin/plugin.json" 2>/dev/null || echo "MISSING")
            echo "  $name: marketplace=$mp_version, plugin.json=$pj_version"
            if [ "$mp_version" != "$pj_version" ]; then
              PLUGIN_MISMATCHES="$PLUGIN_MISMATCHES $name(mp=$mp_version,pj=$pj_version)"
            fi
          done
          if [ -n "$PLUGIN_MISMATCHES" ]; then
            echo "::error::Plugin version mismatches:$PLUGIN_MISMATCHES"
            echo "Each plugin's plugin.json version must match its marketplace.json plugins[] entry's version."
            exit 1
          fi
          echo "All per-plugin versions in sync"
```

This adds a per-plugin sync check while preserving the existing canonical
`PLUGIN_VERSION` for the README/CHANGELOG-of-canonical-plugin checks.

- [ ] **Step 3: Verify YAML syntax**

Run: `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/version-check.yml'))" && echo OK`
Expected: `OK`

- [ ] **Step 4: Commit**

```bash
git add .github/workflows/version-check.yml
git commit -m "ci: version-check enumerates all marketplace plugins (per O12)"
```

---

## Task 9: AGENTS.md ARCH_DECISIONS — promote trust-architecture pattern

**Files:**

- Modify: `AGENTS.md`

Per stories #7 and #8 promotion in `docs/superpowers/stories/model-cards-plugin-design.md`.

- [ ] **Step 1: Locate insertion point**

Run: `grep -n "^## ARCH_DECISIONS" AGENTS.md`

The new entry goes immediately after the section heading, before the
existing first ARCH_DECISIONS bullet.

- [ ] **Step 2: Insert the new ARCH_DECISIONS bullet**

In `AGENTS.md`, just below the `## ARCH_DECISIONS` header and any HTML
comment block, insert:

```markdown
- Decision: content-emitting agents in this codebase use a three-part trust
  architecture — **agent-emit + dispatcher-persist + human-disposes**. The
  agent's tool boundary is research-and-author only (no Edit, no Bash); the
  agent returns content as a string; the dispatching command writes the file
  after a structured human review (accept / edit / re-run / abort). This
  pattern is in production across three agents: `advocatus-diaboli`,
  `choice-cartographer`, and `model-card-researcher`. Three repetitions
  promote it from convention to named architecture (Hunt/Thomas's Rule of
  Three). Future research-and-author agents in this codebase should default
  to this shape unless an explicit reason argues otherwise. The two halves
  are: (1) tool-boundary — minimum-trust-surface, no shell, no edit; (2)
  human-gate — structured review summary, named dispositions, command
  refuses to persist when the agent emits a refusal string (e.g.
  model-card-researcher's REFUSED: line for unconfirmed model existence).
  Source: `docs/superpowers/stories/model-cards-plugin-design.md` stories
  #7 and #8 (promoted disposition).
```

- [ ] **Step 3: Verify markdownlint**

Run: `npx markdownlint-cli2 AGENTS.md`
Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add AGENTS.md
git commit -m "AGENTS.md: promote trust-architecture pattern from cartograph stories #7+#8"
```

---

## Task 10: Final verification

**Files:** none modified

- [ ] **Step 1: Markdownlint over the whole new plugin and changed root files**

Run:

```bash
npx markdownlint-cli2 \
  "model-cards/**/*.md" \
  "AGENTS.md" \
  "docs/superpowers/specs/2026-04-29-*.md" \
  "docs/superpowers/objections/model-cards-plugin-design.md" \
  "docs/superpowers/stories/model-cards-plugin-design.md" \
  "docs/superpowers/plans/2026-04-29-model-cards-plugin.md"
```

Expected: no errors.

- [ ] **Step 2: JSON validity**

Run:

```bash
jq . .claude-plugin/marketplace.json > /dev/null && \
jq . model-cards/.claude-plugin/plugin.json > /dev/null && \
jq . model-cards/seed/frontier-models.json > /dev/null && \
echo OK
```

Expected: `OK`

- [ ] **Step 3: YAML frontmatter validity for new agent and command**

Run:

```bash
python3 -c "
import yaml
for f in ['model-cards/agents/model-card-researcher.agent.md',
          'model-cards/commands/model-card.md',
          'model-cards/skills/model-cards/SKILL.md']:
    content = open(f).read()
    yaml.safe_load(content.split('---', 2)[1])
    print(f'OK: {f}')
"
```

Expected: three `OK:` lines.

- [ ] **Step 4: Per-plugin version consistency**

Run:

```bash
for name in $(jq -r '.plugins[].name' .claude-plugin/marketplace.json); do
  source=$(jq -r --arg n "$name" '.plugins[] | select(.name == $n) | .source' .claude-plugin/marketplace.json)
  mp_version=$(jq -r --arg n "$name" '.plugins[] | select(.name == $n) | .version' .claude-plugin/marketplace.json)
  pj_version=$(jq -r '.version' "${source}/.claude-plugin/plugin.json")
  echo "$name: marketplace=$mp_version, plugin.json=$pj_version"
  [ "$mp_version" = "$pj_version" ] || { echo "MISMATCH"; exit 1; }
done
echo OK
```

Expected:

```text
ai-literacy-superpowers: marketplace=0.31.1, plugin.json=0.31.1
model-cards: marketplace=0.1.0, plugin.json=0.1.0
OK
```

- [ ] **Step 5: gitleaks scan**

Run: `gitleaks detect --source . --no-banner --exit-code 1`
Expected: no leaks.

- [ ] **Step 6: Manual integration smoke test**

In a fresh terminal with the plugin installed (or with `${CLAUDE_PLUGIN_ROOT}`
pointed at the new `model-cards/` path):

1. Run: `/model-card create claude-opus-4-7 --provider anthropic`
2. Confirm the agent dispatches, performs research (10-30 web fetches), and
   returns a draft card
3. Confirm the review summary shows source-tier counts, sparse-section list,
   top-3 cited claims, estimated cost
4. Accept the draft
5. Confirm the card lands at `~/.claude/model-cards/anthropic/claude-opus-4-7.md`
6. Confirm the card has populated frontmatter, 10 sections, real citations
   resolving via the `sources` block

Then test the refusal path:

1. Run: `/model-card create totally-fake-nonexistent-model --provider nowhere`
2. Confirm the agent returns `REFUSED:` and the command surfaces the refusal
   reason
3. Confirm no file was written to `~/.claude/model-cards/`

Then test seed (with a trimmed list for speed):

1. Backup `model-cards/seed/frontier-models.json`
2. Replace with a 3-model trimmed version
3. Run: `/model-card seed`
4. Confirm the user prompt shows 3 models, accept
5. Confirm 3 cards land in the library
6. Restore the original seed list

- [ ] **Step 7: Open the PR**

```bash
git push -u origin model-cards-plugin
gh pr create --title "model-cards: new sister plugin (v0.1.0)" --body "$(cat <<'EOF'
## Summary

Adds a new sister plugin `model-cards` to the marketplace. Researches and
authors Mitchell-extended model cards from a model name with hybrid
review-before-commit. Ships with a 14-model frontier seed list.

Spec: \`docs/superpowers/specs/2026-04-29-model-cards-plugin-design.md\`
Plan: \`docs/superpowers/plans/2026-04-29-model-cards-plugin.md\`
Diaboli (adjudicated): \`docs/superpowers/objections/model-cards-plugin-design.md\`
Stories (adjudicated): \`docs/superpowers/stories/model-cards-plugin-design.md\`

## What's in the PR

- New plugin at `model-cards/` (manifest, README, CHANGELOG, template, seed,
  skill, agent, command)
- Marketplace listing bumped 0.2.3 → 0.3.0; second `plugins[]` entry added
- `version-check.yml` extended to enumerate plugins via `marketplace.json`
- `AGENTS.md` ARCH_DECISIONS gains a promotion entry for the
  trust-architecture pattern (per cartograph stories #7+#8)

## Tracking issues created during planning

- #232 chore: explore removal of marketplace.json top-level plugin_version
- #233 model-cards: /model-card list subcommand
- #234 model-cards: /model-card compare subcommand
- #235 model-cards: /model-card refresh subcommand

## Test plan

- [x] markdownlint clean
- [x] JSON validity (marketplace.json, plugin.json, frontier-models.json)
- [x] YAML frontmatter parseable for agent and command
- [x] Per-plugin version consistency (both plugins in sync)
- [x] gitleaks scan clean
- [x] Manual integration smoke: create succeeds for known model
- [x] Manual integration smoke: REFUSED path for unknown model
- [x] Manual integration smoke: trimmed-seed populate
- [ ] CI green
EOF
)"
```

---

## Self-Review Notes

**Coverage check** against spec sections:

- Goals 1-6 (single-command flow, tiered sources, hybrid review, per-user
  library, seed subcommand, honest about limits) → Tasks 5, 6 (agent +
  command); Task 4 (skill); Task 2 (template); Task 3 (seed list)
- Architecture (file layout) → Task 1 (scaffold); Tasks 2-6 (per-component
  files)
- Card template → Task 2
- Citation scheme → Task 2 (template), Task 4 (skill), Task 5 (agent
  charter)
- Honesty rules (claim-level + card-level) → Task 5 (agent charter); Task 4
  (skill); Task 1 (README)
- Research agent + tiered strategy → Task 5
- Commands and flows → Task 6
- Storage and library → Task 6 (path resolution logic in command)
- Marketplace integration → Task 7
- Plugin self-versioning → Task 1
- Testing strategy → Task 10 (final verification)

Spec gaps not in tasks:

- O5 card-level honesty rule (model-existence check) — covered in Task 5 +
  Task 4 + Task 6 (REFUSED handling)
- O9 specification picks (--out semantics, etc.) — covered in Task 6
- O10 field-level "Not publicly available" — covered in Task 4 + Task 5
- O12 version-check workflow — covered in Task 8
- Stories #7+#8 promotion — covered in Task 9

All spec content has a task.

**Type/name consistency**:

- Plugin name `model-cards` — same in plugin.json, marketplace.json, README,
  CHANGELOG, file paths
- Command name `/model-card` (singular, no -s) with subcommands — same in
  command file frontmatter, README, agent charter
- Agent name `model-card-researcher` — same in agent file, command file
  references, README, AGENTS.md promotion entry
- Citation format `[T<n>.<m>]` — same in template, skill, agent charter
- Library path `~/.claude/model-cards/<provider>/<model-name>.md` — same in
  README, command, spec
- Tier numbering 1=provider docs, 2=HuggingFace, 3=arXiv, 4=web — same
  throughout

**Placeholder scan**: no TBD/TODO/FIXME placeholders. Every step has actual
code or actual commands. Where the agent's content is partly free-form
(e.g. card body), the constraints (10 sections, citation format, honesty
rules) are explicit.

**Scope check**: 10 tasks, single concern (build the plugin), single PR.
Tracking issues capture deferred scope. Tractable.
