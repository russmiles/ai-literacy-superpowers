---
spec: docs/superpowers/specs/2026-04-29-model-cards-plugin-design.md
date: 2026-04-29
mode: spec
cartographer_model: claude-opus-4-7[1m]
stories:
  - id: 1
    lens: [alternatives, defaults, consequences]
    title: Plugin shape inherited from question framing
    disposition: accepted
    disposition_rationale: "Plugin shape was deliberate, just unevidenced in the Decisions table. The diaboli's O3 adjudication recorded the substantive reasons (CLI lacks Claude-Code coupling; personal repo lacks discoverability; single-skill lacks coherent invocation surface). Accepted as-written."
  - id: 2
    lens: [alternatives, consequences]
    title: Mitchell-extended makes cards a derivative
    disposition: accepted
    disposition_rationale: "Honesty is in the naming. 'Mitchell-extended' is a permanent flag that future readers can use to distinguish this plugin's cards from canon. Interoperability with strict-Mitchell tooling is not a stated goal of this plugin. Accepted as-written."
  - id: 3
    lens: [forces, consequences]
    title: Per-user global library outside any project
    disposition: accepted
    disposition_rationale: "Matches stated use case (personal evaluation across whatever project the user is working in). Configurability via --out and MODEL_CARDS_DIR preserves revocability. Team-use scenario is not a v0.1.0 concern; revisit if real team users emerge."
  - id: 4
    lens: [consequences, patterns]
    title: Tier order baked into citation provenance
    disposition: revisit
    disposition_rationale: "Revisit if any source class displaces another in trust hierarchy (e.g. HuggingFace becomes more reliable than provider docs for certain model classes; arXiv preprints become tier-1 for research-disclosed models). Mitigation cost when revisited: add tier-scheme version to card frontmatter and migrate older cards on read. Not a v0.1.0 blocker."
  - id: 5
    lens: [forces, alternatives, consequences]
    title: Seed list as shipped plugin payload
    disposition: revisit
    disposition_rationale: "Revisit after first patch cycle exposes actual maintenance cost. Cadence baseline to commit to in the implementation plan: review seed list quarterly aligned with the plugin's own quarterly operational cadence. If the cadence becomes painful, the dispatch-from-remote alternative or empty-seed-with-add semantics should be reconsidered then."
  - id: 6
    lens: [consequences, patterns]
    title: Section 10 wishlist becomes downstream contract
    disposition: revisit
    disposition_rationale: "Revisit before /model-card compare lands. The wishlist is committed enough to ship and not committed enough to depend on for cross-card analysis. The compare subcommand will force a schema decision; that's the right time to lock the field set, informed by 5+ real cards."
  - id: 7
    lens: [forces, patterns]
    title: Hybrid review as Human-in-the-Loop gate
    disposition: promoted
    disposition_rationale: "Promoted to AGENTS.md ARCH_DECISIONS as part of the 'trust architecture for content-emitting agents' pattern (paired with story 8). Pattern recurs across three agents (advocatus-diaboli, choice-cartographer, model-card-researcher) — Rule of Three — and naming it explicitly compresses the design cost of every future research-and-author agent in this codebase. Promotion happens in the implementation phase, alongside the new agent's introduction."
  - id: 8
    lens: [defaults, patterns]
    title: Research-only tool boundary mirrors diaboli
    disposition: promoted
    disposition_rationale: "Promoted to AGENTS.md ARCH_DECISIONS jointly with story 7. The two stories together articulate one pattern with two halves: tool-boundary (this story) + human-disposition (story 7). Promotion entry will name both halves and reference all three agents that exemplify it."
---

## Story #1 — Plugin shape inherited from question framing

**Source:** `docs/superpowers/specs/2026-04-29-model-cards-plugin-design.md` (Decisions table; Q1–Q6b)
**Lens:** alternatives / defaults / consequences
**Refs:** O3

**Context.** The Decisions table walks Q1 ("what models?") → Q2 ("what sources?") → ... → Q6a ("what name?") → Q6b ("subcommand or multiple top-level?"). Plugin-shape is the substrate every other decision rests on, but it never appears as its own row. The question "should this be a plugin at all?" is answered by the framing of Q1, not by deliberation.

**Forces.** Marketplace discoverability and Claude-Code-native invocation pull toward plugin-shape. Setup cost (manifest, version dance, listing entry, CHANGELOG, README) and the audience-asymmetry reasoning that killed yesterday's Option A–E pull toward smaller shapes. The spec resolves toward plugin-shape silently because the brainstorming session opened with "this plugin" framing and never re-opened it.

**Options not taken.** A personal git repo (cards-as-notes, no Claude-Code coupling). A single skill in the existing `ai-literacy-superpowers` plugin (rejected yesterday on audience grounds, not re-considered today as still viable since "evaluator skill" is a smaller commitment than "evaluator plugin"). A standalone CLI tool invoked from outside Claude Code. A docs page with a copy-paste template.

**Choice as written.** Sister plugin in the existing marketplace, with full plugin scaffolding (manifest, agents/, commands/, skills/, templates/, seed/, CHANGELOG, README). The spec chose plugin-shape by question framing rather than by tabulated trade-off — and the diaboli's O3 rejection rationale records the choice was deliberate, just unevidenced in the Decisions table.

**Consequences.** Plugin-shape now carries forward as a load-bearing assumption for every downstream decision: marketplace listing bump, version-consistency CI scope, semver discipline for the new plugin, CHANGELOG maintenance, tracking-issue cadence for `/model-card list|compare|refresh`. Migrating to a smaller shape later means deprecating the marketplace listing entry (a public-contract change) and migrating any user libraries built against the plugin install path.

**Pattern.** Implicit framing assumption — the spec's first form (a brainstorm) committed to plugin-shape as the unit of work; subsequent specification reasoned within that frame. Closest named cousin is Christopher Alexander's "fundamental error" — the wrong frame produces a coherent answer to the wrong question.

**Notes.** This is the load-bearing decision the diaboli surfaced as O3 and the author adjudicated as accepted. The cartographer's role is to record what's been committed to so that revisiting the plugin shape later is recognisably *that* — a frame revisit, not a tweak.

## Story #2 — Mitchell-extended makes cards a derivative

**Source:** `docs/superpowers/specs/2026-04-29-model-cards-plugin-design.md` (Card template; Decisions Q3)
**Lens:** alternatives / consequences
**Refs:** O11

**Context.** Q3 chose "Mitchell-extended: 9 canonical sections + 10th 'Operational Details' section." The rationale invokes "industry-recognised" as a benefit of Mitchell, then extends Mitchell — a card produced by this plugin is no longer a Mitchell card in the strict sense.

**Forces.** Recognition (Mitchell is a known schema; downstream tooling may consume it) vs. completeness for the consumer-evaluator audience (Mitchell pre-dates the API-pricing / context-window / SDK-support concerns this plugin centres). Self-documentation (an empty Section 10 is more visible than a missing frontmatter field) vs. interoperability (a strict-Mitchell consumer rejects or ignores a 10th section).

**Options not taken.** Strict 9-section Mitchell with operational details in YAML frontmatter (preserves interop; the diaboli's O11 alternative). Two artefacts per model — one strict-Mitchell card and one operational-details sibling. Mitchell-shaped output emitted alongside a separate "operational profile" file. None tabulated in the Decisions table.

**Choice as written.** A 10-section template with Operational Details as the canonical Section 10. Cards from this plugin are "Mitchell-shaped, with operational details" — the diaboli's O11 disposition records this framing explicitly.

**Consequences.** Cards are not portable to strict-Mitchell tooling without dropping or relocating Section 10. Future `/model-card compare` will compare cards within this plugin's schema, not against external Mitchell cards. If a strict-Mitchell standard tightens later (e.g. ACM FAccT publishes a v2), cards in user libraries are derivative artefacts that need migration. The "Mitchell-extended" name is a permanent flag that future readers will use to tell this plugin's cards from canon.

**Pattern.** Schema extension — naming the variant explicitly (Mitchell-*extended*) is the honest framing; the alternative (silent extension under the original name) would be the dishonest one. Closest named pattern: "embrace and extend" carries connotations the spec does not intend; the more neutral framing is "named-derivative schema."

**Notes.** The honesty is in the naming. The decision worth surfacing is not "extend or not" — it is "the fact of extension, and the trade-off accepted, are now part of the plugin's identity, not just its template."

## Story #3 — Per-user global library outside any project

**Source:** `docs/superpowers/specs/2026-04-29-model-cards-plugin-design.md` (Storage and library)
**Lens:** forces / consequences
**Refs:** —

**Context.** Default storage is `~/.claude/model-cards/<provider>/<model-name>.md`. The choice is global-per-user, not project-local. Override mechanisms (`--out`, `MODEL_CARDS_DIR`) layer atop the default but the default is the path 14 cards land in on `seed`.

**Forces.** Cards-as-personal-reference (cross-project value; one researched card serves every project the user works on) vs. cards-as-project-artefact (committed to a repo, version-controlled, shared with collaborators). Persistence across projects (the user's stated use case) vs. portability with a project (no commit dance, no migration when switching machines).

**Options not taken.** Project-local `.claude/model-cards/` (mirrors how many Claude Code conventions live alongside the project they apply to). Repo-committed at a project-chosen path with the plugin reading a project setting. Both-default with the plugin asking on first use.

**Choice as written.** Global-per-user as default; project/path override available but not promoted. The spec frames this as "matches stated use case" — and indeed it does, for a single-user evaluator. It does not weigh the consequence for a team using this plugin.

**Consequences.** Cards built in one project's research session are visible in every other project the same user opens — convenient for the author, surprising for someone discovering the plugin in a team setting where they expect project artefacts to be project-scoped. Revoking the global-default later means migrating users' card collections (a one-time pain that scales with library size) or supporting both defaults indefinitely (config-surface growth). Cards are not version-controlled by default — a card researched today is the only copy unless the user has set up `~/.claude/` backups.

**Pattern.** User-scoped cache — closest cousin in the Claude Code ecosystem is `~/.claude/plugins/marketplaces/`. The decision is consistent with that scoping, which makes it inherited rather than examined.

**Notes.** The configurability options (`--out`, env var) make this revocable in principle; the question is what happens to the libraries already populated against the original default.

## Story #4 — Tier order baked into citation provenance

**Source:** `docs/superpowers/specs/2026-04-29-model-cards-plugin-design.md` (Citation scheme; Tiered source strategy)
**Lens:** consequences / patterns
**Refs:** —

**Context.** Citations resolve as `[T<n>.<m>]` where `n` is the tier (1–4) and `m` is the source index. The tier numbering is the priority order: provider docs (1) → HuggingFace (2) → arXiv (3) → web search (4). The provenance format embeds the priority order into every card.

**Forces.** Compactness (a two-token citation is cheap to read) vs. semantic stability (the meaning of `T1` is "provider docs" only as long as the priority order holds). Per-claim tier-visibility (a reader can tell at a glance whether a claim came from primary or fallback) vs. tier-order portability (changing the priority later changes what `T1` means in old cards).

**Options not taken.** Citations resolved by source-type label (`[provider]`, `[hf]`, `[arxiv]`, `[web]`) — verbose but tier-order-independent. Citations as numbered footnotes with full source detail per claim — verbose but complete. Citations carrying both tier and type (`[T1:provider.1]`) — belt and braces.

**Choice as written.** Tier-only `[T<n>.<m>]` with the meaning of `n` defined by the per-card frontmatter `sources` block. The frontmatter records the URL per tier, so a card is internally consistent — but two cards from different tier orderings would mean different things by the same `[T1.1]` token.

**Consequences.** Changing the priority order later (e.g. demoting HuggingFace from tier 2 to tier 3 because of staleness, or inserting a new tier) changes how a future reader interprets older cards' citations. Mitigation requires either (a) keeping tier-order stable forever, (b) versioning the tier scheme in card frontmatter, or (c) re-running every existing card on tier-order change. None of these are committed to in the spec. The `last_researched` date is the closest signal but does not encode tier-scheme version.

**Pattern.** Provenance-as-format — citation IS the source-trust chain rather than just pointing at it. Closest named pattern: an inversion of canonical-form (Henney) where the format itself encodes the meaning rather than referencing it.

**Notes.** This is a quiet commitment that compounds: every card written under v0.1.0's tier scheme is forever interpretable only against v0.1.0's priority order. Worth `revisit` consideration if any source class displaces another in trust hierarchy.

## Story #5 — Seed list as shipped plugin payload

**Source:** `docs/superpowers/specs/2026-04-29-model-cards-plugin-design.md` (Initial seed list; `frontier-models.json`)
**Lens:** forces / alternatives / consequences
**Refs:** O8

**Context.** `seed/frontier-models.json` ships 14 named frontier models (Anthropic ×3, OpenAI ×4, Google ×2, Meta, Mistral, xAI, Cohere, Alibaba). The list is part of the plugin payload — installing the plugin installs the list.

**Forces.** Instant value on first install (a fresh install with a populated seed list lets `/model-card seed` do something the moment it arrives) vs. content currency (named frontier models age fast — names like `gpt-5`, `o4`, `llama-4`, `grok-4` may be retired or renamed within a release cycle). Author-curated quality (14 hand-picked models, balanced across providers) vs. user-extensibility (the list is a JSON file the user can edit, but each plugin update may overwrite local edits).

**Options not taken.** Empty seed shipped with `--add` semantics (user populates from zero — no staleness risk, no instant-value either). Fetch-from-remote with offline fallback (current list always; couples plugin to an external service the author does not control — the diaboli's O8 alternative the author judged worse). Provider-grouped sub-seeds (ship `--providers anthropic,openai` defaults, full set on flag).

**Choice as written.** Embedded JSON list as shipped content. The diaboli's O8 disposition records the trade-off: patch releases for seed updates are the operational cost the author accepts in exchange for instant-functional first-install.

**Consequences.** The plugin now has a content-maintenance contract not implied by code-only plugins: seed updates require version bumps and CHANGELOG entries. Trimming the list later removes content from the install — users who installed v0.1.x and ran `/model-card seed` may have cards in their library for models the new shipped list no longer mentions. Adding models (especially as new frontier entries appear) is the more common direction, but each addition is a patch release. Renaming a model in the list (e.g. `o4` → `o5`) leaves users with cards under the old name unless `/model-card refresh` (a future subcommand) bridges them.

**Pattern.** Curated-default-as-content — the package ships taste, not just code. Common in Linux distro defaults and editor starter configs; less common in plugin-shaped tooling. Closest named pattern: opinionated defaults (Rails) but applied to data rather than configuration.

**Notes.** The implementation plan should record the cadence the author is committing to (e.g. "review seed list quarterly") so that "worth a reflection if cadence becomes onerous" has a baseline to compare against.

## Story #6 — Section 10 wishlist becomes downstream contract

**Source:** `docs/superpowers/specs/2026-04-29-model-cards-plugin-design.md` (Card template, Section 10)
**Lens:** consequences / patterns
**Refs:** O10

**Context.** Section 10 is described in one sentence: "Pricing (input/output per million tokens), context window, knowledge cutoff, supported APIs/SDKs, latency tier, tool/structured-output support, function calling, fine-tuning availability, rate limit notes." No required-vs-optional marking, no per-field schema, no per-field honesty rule for absence vs. inapplicability.

**Forces.** Schema strictness (downstream tooling — especially the future `/model-card compare` — needs a stable field set to compare reliably) vs. schema discovery (locking down fields in v0.1.0 risks committing to the wrong set before real cards reveal which fields matter). Author velocity (one-sentence wishlist is fast) vs. implementer determinism (two reasonable implementers will produce different field sets given the same sentence).

**Options not taken.** A sub-template within Section 10 with explicit required/optional markers per field. A YAML schema in frontmatter (machine-readable; enforceable; forecloses Section 10 as the rendering surface). A "minimum viable Section 10" naming only the 3–4 highest-priority fields with the rest as optional extensions.

**Choice as written.** Comma-separated wishlist with field-level "Not publicly available" as the canonical absence signal (per the diaboli's O10 disposition). The implementation will treat all listed fields as best-effort.

**Consequences.** The set of fields named in Section 10's sentence becomes the de facto contract for what downstream tooling expects. Adding a field later means existing cards lack it (silently or explicitly?). Removing a field means existing cards have it as residue. `/model-card compare` cannot rely on field presence/absence to distinguish "research gap" from "not applicable to this model." Schema migration tools become a v0.2 problem because v0.1 has no schema to migrate from — only a wishlist that ossifies into one.

**Pattern.** Wishlist-as-schema — common in early-version specs and almost universally regretted at v0.x → v1.0. The diaboli's O10 disposition acknowledges this risk and accepts it; the cartographer's role is to record that the wishlist IS the schema until something replaces it.

**Notes.** The honest disposition for this story is likely `revisit` — the field set is committed enough to ship and not committed enough to depend on for cross-card analysis.

## Story #7 — Hybrid review as Human-in-the-Loop gate

**Source:** `docs/superpowers/specs/2026-04-29-model-cards-plugin-design.md` (Q4; `/model-card create` flow)
**Lens:** forces / patterns
**Refs:** —

**Context.** Q4 chose "command + autonomous research + review-before-commit." The create flow ends in a review step where the user accepts / edits / re-runs / aborts before the card lands in the library. The diaboli explicitly did not object to this — the design is named load-bearing for trustworthy cards.

**Forces.** Throughput (autonomous research over a 14-model seed list completes faster without per-card review) vs. trust integrity (AI-generated content lands in a global library that the user reads later as if it were a researched note). Author cognitive load (review is friction) vs. failure-cost asymmetry (a bad card in the library is much costlier to find and fix than a moment of review).

**Options not taken.** Fully autonomous (write directly; trust the agent's citation discipline). Fully manual (agent presents research; human authors the card). Async review (write to a staging path; user reviews and promotes later) — tabulated nowhere but a real shape.

**Choice as written.** Synchronous review-before-commit, with structured summary (sources per section, "Not publicly available" count, top 3 most-cited claims, estimated cost) — a designed checkpoint, not an afterthought. The seed flow opts out of per-card review and replaces it with a single batch confirmation, which makes the seed flow's trust profile different from create's and is worth noting as a related sub-decision.

**Consequences.** Trust in the library depends on review actually being exercised — a user who routinely accepts without reading recreates the failure mode the gate exists to prevent. The gate is structurally identical to `advocatus-diaboli`'s human-disposition gate (agent emits, human disposes) — and inherits the same limitation: a checkbox that no one looks at is not a gate.

**Pattern.** Human-in-the-Loop with structured summary — close to Norman's "forcing function" applied to AI output. In the project's own pattern language, this mirrors the diaboli/cartographer disposition gate: agent-emit + human-decide + tool-boundary-prevents-bypass. Naming the pattern matters because future research-and-author agents in this codebase should default to it; without the name, each new agent re-derives the design.

**Notes.** This is the cartographer's highest-leverage move on this spec — naming the pattern compresses the cognitive cost of every future agent in this family. The design is sound; the story's job is to make the pattern explicit so it can be reused by name.

## Story #8 — Research-only tool boundary mirrors diaboli

**Source:** `docs/superpowers/specs/2026-04-29-model-cards-plugin-design.md` (Research agent; Tools)
**Lens:** defaults / patterns
**Refs:** #7

**Context.** The model-card-researcher agent is given `WebFetch, WebSearch, Read, Write, Glob, Grep` and explicitly denied `Edit` and `Bash`. Output is a single markdown string returned to the dispatching command, which writes the file.

**Forces.** Capability completeness (research needs web fetch and search; output needs write) vs. blast radius (Edit + Bash add code-modification and shell-execution surfaces an authoring agent does not need). Agent autonomy (more tools = more independent operation) vs. trust-boundary clarity (fewer tools = clearer reasoning about what the agent could possibly do).

**Options not taken.** Full toolset minus an explicit denylist (more permissive default). Read-only research with a separate writer agent (more processes, fewer tools per agent). Single tool (`WebFetch` only) with research-as-text and the dispatcher doing the rest.

**Choice as written.** Minimum-trust-surface for research-and-author: tools sufficient for the job, denied for everything beyond. The agent does not write the file directly — the command writes it after review. This separation of "agent emits content" from "command persists content" is the same separation the cartographer agent itself uses (Read/Glob/Grep only, output returned for the orchestrator to write).

**Consequences.** The pattern of "agent emits, dispatcher persists, human reviews" is now repeated three times in this codebase (diaboli, cartographer, model-card-researcher). Three repetitions are a pattern (Hunt/Thomas's *Rule of Three*) — the project should consider naming it explicitly in AGENTS.md so future agents inherit by reference rather than convention.

**Pattern.** Read-only-emitter + write-by-dispatcher — a project-local pattern not yet named. Closest cousins in the literature: the Two-Phase Commit pattern (the agent's "prepare" is the emit; the dispatcher's "commit" is the persist) and the Command-Query Separation principle (agent answers a query; command performs the action).

**Notes.** Story #7 named the human-disposition gate; this story names the agent-tool-boundary half of the same pattern. Together they form the project's de facto trust architecture for content-emitting agents — and that architecture is worth promoting (per the disposition's `promoted` value) to AGENTS.md as an ARCH_DECISION so the next research-and-author agent inherits it without re-derivation.
